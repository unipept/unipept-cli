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

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2taxa --host http://api.unipept.ugent.be --batch 2 >test EGGAGSSTGQR ENFVYIAK >tost EGGAGSSTGQR))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'fasta_header,peptide,taxon_id,taxon_name,taxon_rank')
      assert(lines.select { |line| line.start_with? '>test,EGGAGSSTGQR,' }.size >= 1)
      assert(lines.select { |line| line.start_with? '>test,ENFVYIAK,' }.size >= 1)
      assert(lines.select { |line| line.start_with? '>tost,EGGAGSSTGQR,' }.size >= 1)
    end
  end
end
