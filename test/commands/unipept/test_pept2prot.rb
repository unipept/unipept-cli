require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2protTestCase < Unipept::TestCase
    def test_batch_size
      command = Cri::Command.define { name 'pept2lca' }
      pept2lca = Commands::Pept2prot.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(10, pept2lca.batch_size)
      pept2lca.options[:all] = true
      assert_equal(5, pept2lca.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2prot -h))
        end
      end
      assert(out.include? 'show help for this command')

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2prot --help))
        end
      end
      assert(out.include? 'show help for this command')
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2prot --host http://api.unipept.ugent.be ENFVYIAK))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'peptide,uniprot_id,taxon_id')
      assert(lines.next.start_with? 'ENFVYIAK,')
    end
  end
end
