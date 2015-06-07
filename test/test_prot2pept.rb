require_relative '../lib/prot2pept'

module Unipept
  class Prot2peptTestCase < Unipept::TestCase
    def test_normal_input
      out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(%w())
      end
      assert_equal("AALTER\nAALTERPAALTER", out.chomp)

      out, _err = capture_io_with_input('KRKPR') do
        Prot2pept.run(%w())
      end
      assert_equal("K\nR\nKPR", out.chomp)

      out, _err = capture_io_with_input(%w(AALTERAALTERPAALTER AALTERAA)) do
        Prot2pept.run(%w())
      end
      assert_equal("AALTER\nAALTERPAALTER\nAALTER\nAA", out.chomp)
    end

    def test_fasta_input
      out, _err = capture_io_with_input(">AKA\nAALTERAALTERPAALTER") do
        Prot2pept.run(%w())
      end
      assert_equal(">AKA\nAALTER\nAALTERPAALTER", out.chomp)

      out, _err = capture_io_with_input(">AKA\nAAL\nT\nERAALTER\nP\nAALTER") do
        Prot2pept.run(%w())
      end
      assert_equal(">AKA\nAALTER\nAALTERPAALTER", out.chomp)

      out, _err = capture_io_with_input(">AKA\nAAL\nT\n>\nERAALTER\nP\nAALTER") do
        Prot2pept.run(%w())
      end
      assert_equal(">AKA\nAALT\n>\nER\nAALTERPAALTER", out.chomp)
    end

    def test_default_pattern
      default_out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(%w())
      end
      assert_equal("AALTER\nAALTERPAALTER", default_out.chomp)

      pattern_out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(['-p', '([KR])([^P])'])
      end
      assert_equal(default_out, pattern_out)

      pattern_out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(['--pattern', '([KR])([^P])'])
      end
      assert_equal(default_out, pattern_out)
    end

    def test_pattern
      out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(%w())
      end
      assert_equal("AALTER\nAALTERPAALTER", out.chomp)

      out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(%w(-p ([KR])([^A])))
      end
      assert_equal("AALTERAALTER\nPAALTER", out.chomp)

      out, _err = capture_io_with_input('AALTERAALTERPAALTER') do
        Prot2pept.run(%w(--pattern ([KR])([^A])))
      end
      assert_equal("AALTERAALTER\nPAALTER", out.chomp)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Prot2pept.run(%w(-h))
        end
      end
      assert(out.include? 'show help for this command')
    end
  end
end
