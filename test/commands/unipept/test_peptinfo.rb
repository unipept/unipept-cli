require_relative '../../../lib/commands'

module Unipept
  class UnipeptPeptinfoTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'peptinfo' }
      peptinfo = Commands::Peptinfo.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, peptinfo.default_batch_size)
      peptinfo.options[:all] = true
      assert_equal(100, peptinfo.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'peptinfo' }
      peptinfo = Commands::Peptinfo.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], peptinfo.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'peptinfo' }
      peptinfo = Commands::Peptinfo.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, peptinfo.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'peptinfo' }
      peptinfo = Commands::Peptinfo.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, peptinfo.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[peptinfo -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[peptinfo --help])
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('AALTER,7,1,root,no rank,3.1.3.3,2,GO:0000287,5,IPR013221,2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be --batch 2 >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('fasta_header,peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('>test,AALTER,7,1,root,no rank,3.1.3.3,2,GO:0000287,5,IPR013221,2', lines.next.rstrip)
      assert_equal('>test,AALER,208,1,root,no rank,6.1.1.16,44,GO:0005737,106,IPR014729 IPR009080 IPR015803,48 45 44', lines.next.rstrip)
      assert_equal('>tost,AALTER,7,1,root,no rank,3.1.3.3,2,GO:0000287,5,IPR013221,2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_and_select
      out, err = capture_io_while do
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be --batch 2 --select go_term >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('fasta_header,peptide,go_term', lines.next.rstrip)
      assert_equal('>test,AALTER,GO:0000287', lines.next.rstrip)
      assert_equal('>test,AALER,GO:0005737', lines.next.rstrip)
      assert_equal('>tost,AALTER,GO:0000287', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be --batch 2 --format json >test AALTER AALER >tost AALTER])
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
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be --batch 2 --format xml >test AALTER AALER >tost AALTER])
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
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be AKVYSKY])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_empty_and_existing_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be AKVYSKY AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('peptide,total_protein_count,taxon_id,taxon_name,taxon_rank,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('AALTER,7,1,root,no rank,3.1.3.3,2,GO:0000287,5,IPR013221,2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_existing_peptide_no_go_terms
      out, err = capture_io_while do
        Commands::Unipept.run(%w[peptinfo --host http://api.unipept.ugent.be AAEVALVGTEK])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('peptide,total_protein_count,taxon_id,taxon_name,taxon_rank', lines.next.rstrip)
      assert_equal('AAEVALVGTEK,0,1,root,no rank', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end
  end
end
