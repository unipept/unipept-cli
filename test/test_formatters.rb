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

    def object
      "{list : ['a', 'b', 'c'], key : 'value'}"
    end

    def object
      "{list : ['a', 'b', 'c'], key : 'value'}"
    end

    def test_header
      assert_equal('', formatter.header(object))
    end

    def test_type
      assert_equal('', formatter.type)
    end

    def test_format
      assert_equal(object, formatter.format(object))
    end
  end

  class JSONFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('json')
    end

    def object
      "{list : ['a', 'b', 'c'], key : 'value'}"
    end

    def test_header
      assert_equal('', formatter.header(object))
    end

    def test_type
      assert_equal('json', formatter.type)
    end

    def test_format
      assert_equal(object.to_json, formatter.format(object))
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

    def object
      "{list : ['a', 'b', 'c'], key : 'value'}"
    end

    def test_header
      assert_equal('', formatter.header(object))
    end

    def test_type
      assert_equal('xml', formatter.type)
    end

    def test_format
      assert_equal(object.to_xml, formatter.format(object))
    end
  end
end
