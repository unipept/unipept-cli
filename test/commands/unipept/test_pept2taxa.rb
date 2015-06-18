require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2taxaTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2taxa' }
      pept2taxa = Commands::Pept2taxa.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(10, pept2taxa.default_batch_size)
      pept2taxa.options[:all] = true
      assert_equal(5, pept2taxa.default_batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2taxa -h))
        end
      end
      assert(out.include? 'show help for this command')

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2taxa --help))
        end
      end
      assert(out.include? 'show help for this command')
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2taxa --host http://api.unipept.ugent.be ENFVYIAK))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'peptide,taxon_id,taxon_name,taxon_rank')
      assert(lines.next.start_with? 'ENFVYIAK,')
    end
  end
end
