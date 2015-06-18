require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2lcaTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2lca' }
      pept2lca = Commands::Pept2lca.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2lca.default_batch_size)
      pept2lca.options[:all] = true
      assert_equal(100, pept2lca.default_batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'pept2lca' }
      pept2lca = Commands::Pept2lca.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2lca.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2lca -h))
        end
      end
      assert(out.include? 'show help for this command')

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2lca --help))
        end
      end
      assert(out.include? 'show help for this command')
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2lca --host http://api.unipept.ugent.be AALTER))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'peptide,taxon_id')
      assert(lines.next.start_with? 'AALTER,1,root,no rank')
      assert_raises(StopIteration) { lines.next }
    end
  end
end
