require_relative '../../../lib/commands'

module Unipept
  class UnipeptProtinfoTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'protinfo' }
      protinfo = Commands::Protinfo.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, protinfo.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'protinfo' }
      protinfo = Commands::Protinfo.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['protein'], protinfo.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'protinfo' }
      protinfo = Commands::Protinfo.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, protinfo.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'protinfo' }
      protinfo = Commands::Protinfo.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, protinfo.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[protinfo -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[protinfo --help])
        end
      end
      assert(out.include?('show help for this command'))
    end
end
