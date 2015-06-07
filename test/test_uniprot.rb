require_relative '../lib/uniprot'

module Unipept
  class UniprotTestCase < Unipept::TestCase
    def test_argument_input
      out, _err = capture_io_while do
        Uniprot.run(%w(Q6GZX3))
      end
      assert_equal(1, out.split(/\n/).length)

      out, _err = capture_io_while do
        Uniprot.run(%w(Q6GZX3 Q6GZX4))
      end
      assert_equal(2, out.split(/\n/).length)

      out, _err = capture_io_while do
        Uniprot.run(%w(-f fasta Q6GZX3 Q6GZX4))
      end
      assert_equal(2, out.count('>'))

      out, _err = capture_io_while do
        Uniprot.run(%w(--format fasta Q6GZX3 Q6GZX4))
      end
      assert_equal(2, out.count('>'))
    end

    def test_stdin_input
      out, _err = capture_io_with_input('Q6GZX3') do
        Uniprot.run(%w())
      end
      assert_equal(1, out.split(/\n/).length)

      out, _err = capture_io_with_input(%w(Q6GZX3 Q6GZX4)) do
        Uniprot.run(%w())
      end
      assert_equal(2, out.split(/\n/).length)

      out, _err = capture_io_with_input(%w(Q6GZX3 Q6GZX4)) do
        Uniprot.run(%w(-f fasta))
      end
      assert_equal(2, out.count('>'))

      out, _err = capture_io_with_input(%w(Q6GZX3 Q6GZX4)) do
        Uniprot.run(%w(--format fasta))
      end
      assert_equal(2, out.count('>'))
    end

    def test_argument_input_priority
      out, _err = capture_io_with_input('Q6GZX3') do
        Uniprot.run(%w(Q6GZX3 Q6GZX4))
      end
      assert_equal(2, out.split(/\n/).length)

      out, _err = capture_io_with_input(%w(Q6GZX3 Q6GZX4)) do
        Uniprot.run(%w(Q6GZX3))
      end
      assert_equal(1, out.split(/\n/).length)
    end

    def test_invalid_format
      out, err = capture_io_while do
        assert_raises SystemExit do
          Uniprot.run(%w(--format xxx))
        end
      end
      assert_equal('', out)
      assert(err.include? 'xxx is not a valid output format')
    end

    def test_default_format
      out_default, _err = capture_io_while do
        Uniprot.run(%w(Q6GZX3))
      end
      assert_equal(1, out_default.split(/\n/).length)

      out_sequence, _err = capture_io_while do
        Uniprot.run(%w(-f sequence Q6GZX3))
      end
      assert_equal(out_default, out_sequence)

      out_sequence, _err = capture_io_while do
        Uniprot.run(%w(--format sequence Q6GZX3))
      end
      assert_equal(out_default, out_sequence)
    end

    def test_format_options
      # fasta txt xml rdf gff sequence
      out, err = capture_io_while do
        Uniprot.run(%w(-f fasta Q6GZX3))
      end
      assert(!out.empty?)
      assert(err.empty?)

      out, err = capture_io_while do
        Uniprot.run(%w(-f txt Q6GZX3))
      end
      assert(!out.empty?)
      assert(err.empty?)

      out, err = capture_io_while do
        Uniprot.run(%w(-f xml Q6GZX3))
      end
      assert(!out.empty?)
      assert(err.empty?)

      out, err = capture_io_while do
        Uniprot.run(%w(-f rdf Q6GZX3))
      end
      assert(!out.empty?)
      assert(err.empty?)

      out, err = capture_io_while do
        Uniprot.run(%w(-f gff Q6GZX3))
      end
      assert(!out.empty?)
      assert(err.empty?)

      out, err = capture_io_while do
        Uniprot.run(%w(-f sequence Q6GZX3))
      end
      assert(!out.empty?)
      assert(err.empty?)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Peptfilter.run(%w(-h))
        end
      end
      assert(out.include? 'show help for this command')
    end
  end
end
