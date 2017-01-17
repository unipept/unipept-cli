require_relative '../../lib/commands'

module Unipept
  class UnipeptTestCase < Unipept::TestCase
    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(-h))
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(--help))
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_no_valid_subcommand
      _out, err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w())
        end
      end
      assert(err.include?('show help for this command'))
    end

    def test_version
      out, _err = capture_io_while do
        Commands::Unipept.run(%w(-v))
      end
      assert_equal(VERSION, out.chomp)
    end
  end
end
