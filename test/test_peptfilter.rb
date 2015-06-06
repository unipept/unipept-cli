require_relative '../lib/peptfilter'

module Unipept
  class PeptfilterTestCase < Unipept::TestCase
    def test_length_filter
      # min length
      assert(Peptfilter.filter_length('AALER', 4, 10))
      assert(Peptfilter.filter_length('AALER', 5, 10))
      assert(!Peptfilter.filter_length('AALER', 6, 10))

      # max length
      assert(!Peptfilter.filter_length('AALER', 1, 4))
      assert(Peptfilter.filter_length('AALER', 1, 5))
      assert(Peptfilter.filter_length('AALER', 1, 6))
    end

    def test_lacks_filter
      assert(Peptfilter.filter_lacks('AALER', ''.chars.to_a))
      assert(Peptfilter.filter_lacks('AALER', 'BCD'.chars.to_a))
      assert(!Peptfilter.filter_lacks('AALER', 'A'.chars.to_a))
      assert(!Peptfilter.filter_lacks('AALER', 'AE'.chars.to_a))
    end

    def test_contains_filter
      assert(Peptfilter.filter_contains('AALER', ''.chars.to_a))
      assert(Peptfilter.filter_contains('AALER', 'A'.chars.to_a))
      assert(Peptfilter.filter_contains('AALER', 'AE'.chars.to_a))
      assert(!Peptfilter.filter_contains('AALER', 'BCD'.chars.to_a))
      assert(!Peptfilter.filter_contains('AALER', 'AB'.chars.to_a))
    end

    def test_filter
      assert(Peptfilter.filter('AALTER', 4, 10, 'BCD'.chars.to_a, 'AL'.chars.to_a))
      assert(!Peptfilter.filter('AALTER', 7, 10, 'BCD.chars.to_a', 'AL'.chars.to_a))
      assert(!Peptfilter.filter('AALTER', 4, 5, 'BCD'.chars.to_a, 'AL'.chars.to_a))
      assert(!Peptfilter.filter('AALTER', 4, 10, 'ABC'.chars.to_a, 'AL'.chars.to_a))
      assert(!Peptfilter.filter('AALTER', 4, 10, 'BCD'.chars.to_a, 'ALC'.chars.to_a))
    end

    def test_default_min_length_argument
      out, _err = capture_io_with_input('A' * 6) do
        Peptfilter.run(%w())
      end
      assert_equal('A' * 6, out.chomp)
      out, _err = capture_io_with_input('A' * 5) do
        Peptfilter.run(%w())
      end
      assert_equal('A' * 5, out.chomp)
      out, _err = capture_io_with_input('A' * 4) do
        Peptfilter.run(%w())
      end
      assert_equal('', out.chomp)
    end

    def test_default_max_length_argument
      out, _err = capture_io_with_input('A' * 49) do
        Peptfilter.run(%w())
      end
      assert_equal('A' * 49, out.chomp)
      out, _err = capture_io_with_input('A' * 50) do
        Peptfilter.run(%w())
      end
      assert_equal('A' * 50, out.chomp)
      out, _err = capture_io_with_input('A' * 51) do
        Peptfilter.run(%w())
      end
      assert_equal('', out.chomp)
    end

    def test_with_min_argument
      out, _err = capture_io_with_input('A' * 6) do
        Peptfilter.run(%w(--minlen 7))
      end
      assert_equal('', out.chomp)
      out, _err = capture_io_with_input('A' * 4) do
        Peptfilter.run(%w(--minlen 3))
      end
      assert_equal('A' * 4, out.chomp)
    end

    def test_with_max_argument
      out, _err = capture_io_with_input('A' * 45) do
        Peptfilter.run(%w(--maxlen 40))
      end
      assert_equal('', out.chomp)
      out, _err = capture_io_with_input('A' * 55) do
        Peptfilter.run(%w(--maxlen 60))
      end
      assert_equal('A' * 55, out.chomp)
    end

    def test_with_lacks_argument
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(--lacks B))
      end
      assert_equal('A' * 10, out.chomp)
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(-l B))
      end
      assert_equal('A' * 10, out.chomp)
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(--lacks A))
      end
      assert_equal('', out.chomp)
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(-l A))
      end
      assert_equal('', out.chomp)
    end

    def test_with_contains_argument
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(--contains A))
      end
      assert_equal('A' * 10, out.chomp)
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(-c A))
      end
      assert_equal('A' * 10, out.chomp)
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(--contains B))
      end
      assert_equal('', out.chomp)
      out, _err = capture_io_with_input('A' * 10) do
        Peptfilter.run(%w(-c B))
      end
      assert_equal('', out.chomp)
    end

    def test_fasta_input
      out, _err = capture_io_with_input('>') do
        Peptfilter.run(%w())
      end
      assert_equal('>', out.chomp)
      out, _err = capture_io_with_input(['>', 'A', 'AALTER', '>']) do
        Peptfilter.run(%w())
      end
      assert_equal(">\nAALTER\n>", out.chomp)
    end

    def test_normal_input
      out, _err = capture_io_with_input(['A', 'A' * 11, 'AAAAB', 'BBBBB', 'CCCCC', 'CCCCCA']) do
        Peptfilter.run(%w(--minlen 4 --maxlen 10 --lacks B --contains A))
      end
      assert_equal('CCCCCA', out.chomp)
    end
  end
end
