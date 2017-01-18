require_relative '../lib/formatters'

module Unipept
  class FormattersTestCase < Unipept::TestCase
    def test_available_formatters
      formatters = Formatter.available
      assert(formatters.include?('json'))
      assert(formatters.include?('csv'))
      assert(formatters.include?('xml'))
      assert(formatters.include?('blast'))
    end

    def test_default_formatter
      assert_equal('csv', Formatter.default)
    end

    def test_formatter_registration
      assert(!(Formatter.available.include? 'test'))
      Formatter.register(:test)
      assert(Formatter.available.include?('test'))
    end

    def test_new_for_format
      formatter = Formatter.new_for_format('json')
      assert_equal('json', formatter.type)

      formatter = Formatter.new_for_format('xml')
      assert_equal('xml', formatter.type)

      formatter = Formatter.new_for_format('csv')
      assert_equal('csv', formatter.type)

      formatter = Formatter.new_for_format('blast')
      assert_equal('blast', formatter.type)

      formatter = Formatter.new_for_format('blah')
      assert_equal('csv', formatter.type)
    end

    def test_group_by_first_key
      array = [{ key1: 'v1', key2: 'v2' }, { key1: 'v1', key2: 'v3' }, { key1: 'v4', key2: 'v2' }]
      grouped = formatter.group_by_first_key(array)
      assert_equal({ 'v1' => [{ key1: 'v1', key2: 'v2' }, { key1: 'v1', key2: 'v3' }], 'v4' => [{ key1: 'v4', key2: 'v2' }] }, grouped)
    end

    def test_integrate_fasta_headers
      fasta = [['>test', '5']]
      object = [TestObject.test_object, TestObject.test_object]
      integrated = Array.new(2, { fasta_header: '>test' }.merge(TestObject.test_object))
      assert_equal(integrated, formatter.integrate_fasta_headers(object, fasta))
    end

    def formatter
      Formatter.new
    end

    def test_header
      assert_raises NotImplementedError do
        formatter.header(TestObject.test_object, nil)
      end
    end

    def test_footer
      assert_raises NotImplementedError do
        formatter.footer
      end
    end

    def test_type
      assert_raises NotImplementedError do
        formatter.type
      end
    end

    def test_format
      f = formatter
      def f.integrate_fasta_headers(_a, _b)
        puts 'header'
      end

      def f.convert(_a, _b)
        'body'
      end
      assert_equal('body', f.format(TestObject.test_object, nil, false))
      out, _err = capture_io_while do
        assert_equal('body', f.format(TestObject.test_object, [], false))
      end
      assert_equal('header', out.chomp)
    end

    def test_convert
      assert_raises NotImplementedError do
        formatter.convert(TestObject.test_object, false)
      end
    end
  end

  class JSONFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('json')
    end

    def test_header
      assert_equal('[', formatter.header(TestObject.test_object, nil))
    end

    def test_footer
      assert_equal("]\n", formatter.footer)
    end

    def test_type
      assert_equal('json', formatter.type)
    end

    def test_convert
      assert_equal(TestObject.as_json, formatter.convert([TestObject.test_object], true))
      assert_equal(',' + TestObject.as_json, formatter.convert([TestObject.test_object], false))
    end

    def test_format_with_fasta
      fasta = [['>test', '5']]
      output = formatter.format([TestObject.test_object], fasta, true)
      json = '{"fasta_header":">test","integer":5,"string":"string","list":["a",2,false]}'
      assert_equal(json, output)
    end
  end

  class BlastFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('blast')
    end

    def test_header
      assert_equal('', formatter.header(nil, nil))
    end

    def test_footer
      assert_equal('', formatter.footer)
    end

    def test_type
      assert_equal('blast', formatter.type)
    end

    def test_convert
      object = [{ 'peptide' => 'MDGTEYIIVK', 'refseq_protein_ids' => 'WP_008705701.1' }, { 'peptide' => 'ISVAQGASK', 'refseq_protein_ids' => 'NP_003881.2 XP_011547112.1 XP_011547113.1' }, { 'peptide' => 'ISVAQGASK', 'refseq_protein_ids' => '' }]
      output = "MDGTEYIIVK\tref|WP_008705701.1|\t100\t10\t0\t0\t0\t10\t0\t10\t1e-100\t100\nISVAQGASK\tref|NP_003881.2 XP_011547112.1 XP_011547113.1|\t100\t10\t0\t0\t0\t10\t0\t10\t1e-100\t100\n"
      assert_equal(output, formatter.convert(object, true))
      assert_equal(output, formatter.convert(object, false))
    end
  end

  class CSVFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('csv')
    end

    def test_header
      fasta = [['peptide', '>test']]
      object = [TestObject.test_object, TestObject.test_object]
      assert_equal(TestObject.as_csv_header, formatter.header(object))
      assert_equal('fasta_header,' + TestObject.as_csv_header, formatter.header(object, fasta))
    end

    def test_footer
      assert_equal('', formatter.footer)
    end

    def test_type
      assert_equal('csv', formatter.type)
    end

    def test_convert
      object = [TestObject.test_object, TestObject.test_object]
      csv = [TestObject.as_csv, TestObject.as_csv, ''].join("\n")
      assert_equal(csv, formatter.convert(object, true))
      assert_equal(csv, formatter.convert(object, false))
    end

    def test_format_with_fasta
      fasta = [['>test', '5']]
      object = [TestObject.test_object, TestObject.test_object]
      csv = ['>test,' + TestObject.as_csv, '>test,' + TestObject.as_csv, ''].join("\n")
      assert_equal(csv, formatter.format(object, fasta, false))
    end
  end

  class XMLFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('xml')
    end

    def test_header
      assert_equal('<results>', formatter.header(TestObject.test_object))
    end

    def test_footer
      assert_equal("</results>\n", formatter.footer)
    end

    def test_type
      assert_equal('xml', formatter.type)
    end

    def test_convert
      xml = '<result>' + TestObject.as_xml + '</result>'
      assert_equal(xml, formatter.convert([TestObject.test_object], true))
      assert_equal(xml, formatter.convert([TestObject.test_object], false))
    end

    def test_format_with_fasta
      fasta = [['>test', '5']]
      output = formatter.format([TestObject.test_object], fasta, false)
      xml = '<result><fasta_header>>test</fasta_header>' + TestObject.as_xml + '</result>'
      assert_equal(xml, output)
    end
  end

  class TestObject
    def self.test_object
      JSON.parse('{"integer": 5, "string": "string", "list": ["a", 2, false]}')
    end

    def self.as_json
      '{"integer":5,"string":"string","list":["a",2,false]}'
    end

    def self.as_xml
      '<integer>5</integer><string>string</string><list><item>a</item><item>2</item><item>false</item></list>'
    end

    def self.as_csv
      '5,string,"[""a"", 2, false]"'
    end

    def self.as_csv_header
      "integer,string,list\n"
    end
  end
end
