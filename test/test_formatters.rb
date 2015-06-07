require_relative '../lib/formatters'

module Unipept
  class FormattersTestCase < Unipept::TestCase
    def test_available_formatters
      assert_equal(%w(json csv xml).sort, Formatter.available.sort)
    end

    def test_default_formatter
      assert_equal('csv', Formatter.default)
    end

    def test_formatter_registration
      assert_equal(%w(json csv xml).sort, Formatter.available.sort)
      Formatter.register(:test)
      assert_equal(%w(json csv xml test).sort, Formatter.available.sort)
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
  end

  class JSONFormatterTestCase < Unipept::TestCase
    def formatter
      Formatter.new_for_format('json')
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
  end
end
