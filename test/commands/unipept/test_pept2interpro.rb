require_relative '../../../lib/commands'

module Unipept
  class Unipeptpept2interproTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2interpro' }
      pept2interpro = Commands::Pept2interpro.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2interpro.default_batch_size)
      pept2interpro.options[:all] = true
      assert_equal(100, pept2interpro.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'pept2interpro' }
      pept2interpro = Commands::Pept2interpro.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], pept2interpro.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'pept2interpro' }
      pept2interpro = Commands::Pept2interpro.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2interpro.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'pept2interpro' }
      pept2interpro = Commands::Pept2interpro.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2interpro.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2interpro -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2interpro --help])
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('peptide,total_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('AALTER,7,IPR013221 IPR036565 IPR023214,2 2 2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be --batch 2 >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('fasta_header,peptide,total_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('>test,AALTER,7,IPR013221 IPR036565 IPR023214,2 2 2', lines.next.rstrip)
      assert_equal('>test,AALER,208,IPR014729 IPR009080 IPR015803,48 45 44', lines.next.rstrip)
      assert_equal('>tost,AALTER,7,IPR013221 IPR036565 IPR023214,2 2 2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_and_select
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be --batch 2 --select ipr_code >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('fasta_header,peptide,ipr_code', lines.next.rstrip)
      assert_equal('>test,AALTER,IPR013221 IPR036565 IPR023214', lines.next.rstrip)
      assert_equal('>test,AALER,IPR014729 IPR009080 IPR015803', lines.next.rstrip)
      assert_equal('>tost,AALTER,IPR013221 IPR036565 IPR023214', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be --batch 2 --format json >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join('').chomp
      assert(output.start_with?('['))
      assert(output.end_with?(']'))
      assert(!output.include?('}{'))
      assert(output.include?('fasta_header'))
    end

    def test_run_with_fasta_multiple_batches_xml
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be --batch 2 --format xml >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join('').chomp
      assert(output.start_with?('<results>'))
      assert(output.end_with?('</results>'))
      assert(output.include?('<fasta_header>'))
    end

    def test_run_with_empty_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be AKVYSKY])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_empty_and_existing_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be AKVYSKY AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('peptide,total_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('AALTER,7,IPR013221 IPR036565 IPR023214,2 2 2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_existing_peptide_no_ipr_codes
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2interpro --host http://api.unipept.ugent.be VAQFLL])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count'))
      assert(lines.next.start_with?('VAQFLL,0'))
      assert_raises(StopIteration) { lines.next }
    end
  end
end
