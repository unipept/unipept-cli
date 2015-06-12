require_relative '../lib/formatters'

module Unipept
  class FormattersTestCase < Unipept::TestCase
    def test_available_formatters
      formatters = Formatter.available
      assert(formatters.include? 'json')
      assert(formatters.include? 'csv')
      assert(formatters.include? 'xml')
    end

    def test_default_formatter
      assert_equal('csv', Formatter.default)
    end

    def test_formatter_registration
      assert(!(Formatter.available.include? 'test'))
      Formatter.register(:test)
      assert(Formatter.available.include? 'test')
    end

    def test_new_for_format
      formatter = Formatter.new_for_format('json')
      assert_equal('json', formatter.type)

      formatter = Formatter.new_for_format('xml')
      assert_equal('xml', formatter.type)

      formatter = Formatter.new_for_format('csv')
      assert_equal('csv', formatter.type)

      formatter = Formatter.new_for_format('blah')
      assert_equal('csv', formatter.type)
    end

    def formatter
      Formatter.new
    end

    def test_header
      assert_equal('', formatter.header(TestObject.test_object))
    end

    def test_type
      assert_equal('', formatter.type)
    end

    def test_format
      assert_equal(TestObject.test_object, formatter.format(TestObject.test_object))
    end
  end

  class JSONFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('json')
    end

    def test_header
      assert_equal('', formatter.header(TestObject.test_object))
    end

    def test_type
      assert_equal('json', formatter.type)
    end

    def test_format
      assert_equal(TestObject.as_json, formatter.format(TestObject.test_object))
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

    def test_type
      assert_equal('csv', formatter.type)
    end

    def test_format
      object = [TestObject.test_object, TestObject.test_object]
      csv = [TestObject.as_csv, TestObject.as_csv, ''].join("\n")
      assert_equal(csv, formatter.format(object))
    end

    def test_format_with_fasta
      fasta = [['>test', '5']]
      object = [TestObject.test_object, TestObject.test_object]
      csv = ['>test,' + TestObject.as_csv, '>test,' + TestObject.as_csv, ''].join("\n")
      assert_equal(csv, formatter.format(object, fasta))
    end
  end

  class XMLFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('xml')
    end

    def test_header
      assert_equal('', formatter.header(TestObject.test_object))
    end

    def test_type
      assert_equal('xml', formatter.type)
    end

    def test_format
      assert_equal(TestObject.as_xml, formatter.format(TestObject.test_object))
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
      '<integer>5</integer><string>string</string><list size="3"><item>a</item><item>2</item><item>false</item></list>'
    end

    def self.as_csv
      '5,string,"[""a"", 2, false]"'
    end

    def self.as_csv_header
      "integer,string,list\n"
    end
  end
end
