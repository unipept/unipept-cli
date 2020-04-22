require_relative '../../../lib/commands'

module Unipept
  class UnipeptTaxa2TreeTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'taxa2tree' }
      taxa2tree = Commands::Taxa2Tree.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, taxa2tree.default_batch_size)
      taxa2tree.options[:all] = true
      assert_equal(100, taxa2tree.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'taxa2tree' }
      pept2ec = Commands::Pept2ec.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], pept2ec.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'taxa2tree' }
      pept2ec = Commands::Pept2ec.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2ec.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'taxa2tree' }
      pept2ec = Commands::Pept2ec.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2ec.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2ec -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2ec --help])
        end
      end
      assert(out.include?('show help for this command'))
    end
  end
end
