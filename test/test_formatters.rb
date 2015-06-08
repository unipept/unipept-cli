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
      assert_equal('', formatter.header(TestObject.get_object))
    end

    def test_type
      assert_equal('', formatter.type)
    end

    def test_format
      assert_equal(TestObject.get_object, formatter.format(TestObject.get_object))
    end
  end

  class JSONFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('json')
    end

    def test_header
      assert_equal('', formatter.header(TestObject.get_object))
    end

    def test_type
      assert_equal('json', formatter.type)
    end

    def test_format
      assert_equal(TestObject.as_json, formatter.format(TestObject.get_object))
    end
  end

  class CSVFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('csv')
    end
  end

  class XMLFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('xml')
    end

    def test_header
      assert_equal('', formatter.header(TestObject.get_object))
    end

    def test_type
      assert_equal('xml', formatter.type)
    end

    def test_format
      assert_equal(TestObject.as_xml, formatter.format(TestObject.get_object))
    end
  end

  class TestObject
    def self.get_object
      JSON.parse('{"integer": 5, "string": "string", "list": ["a", 2, false]}')
    end

    def self.as_json
      '{"integer":5,"string":"string","list":["a",2,false]}'
    end

    def self.as_xml
      '<integer>5</integer><string>string</string><list size="3"><item>a</item><item>2</item><item>false</item></list>'
    end
  end
end
