require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2protTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2prot' }
      pept2prot = Commands::Pept2prot.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(10, pept2prot.default_batch_size)
      pept2prot.options[:all] = true
      assert_equal(5, pept2prot.default_batch_size)
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

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2prot --host http://api.unipept.ugent.be --batch 2 >test EGGAGSSTGQR ENFVYIAK >tost EGGAGSSTGQR))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'fasta_header,peptide,uniprot_id,taxon_id')
      assert(lines.select { |line| line.start_with? '>test,EGGAGSSTGQR,' }.size >= 1)
      assert(lines.select { |line| line.start_with? '>test,ENFVYIAK,' }.size >= 1)
      assert(lines.select { |line| line.start_with? '>tost,EGGAGSSTGQR,' }.size >= 1)
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2prot --host http://api.unipept.ugent.be --batch 2 --format json >test EGGAGSSTGQR ENFVYIAK >tost EGGAGSSTGQR))
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join('').chomp
      assert(output.start_with? '[')
      assert(output.end_with? ']')
      assert(!output.include?('}{'))
      assert(output.include? 'fasta_header')
    end

    def test_run_with_fasta_multiple_batches_xml
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2prot --host http://api.unipept.ugent.be --batch 2 --format xml >test EGGAGSSTGQR ENFVYIAK >tost EGGAGSSTGQR))
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join('').chomp
      assert(output.start_with? '<results>')
      assert(output.end_with? '</results>')
      assert(output.include? '<fasta_header>')
    end
  end
end
