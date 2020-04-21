require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2functTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2funct' }
      pept2funct = Commands::Pept2funct.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2funct.default_batch_size)
      pept2funct.options[:all] = true
      assert_equal(100, pept2funct.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'pept2funct' }
      pept2funct = Commands::Pept2funct.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], pept2funct.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'pept2funct' }
      pept2funct = Commands::Pept2funct.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2funct.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'pept2funct' }
      pept2funct = Commands::Pept2funct.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2funct.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2funct -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2funct --help])
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('peptide,total_protein_count,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('AALTER,7,3.1.3.3 6.3.2.13,2 2,GO:0000287 GO:0005737,5 5,IPR013221,2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be --batch 2 >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('fasta_header,peptide,total_protein_count,ec_number,ec_protein_count,go_term,go_protein_count,ipr_code,ipr_protein_count', lines.next.rstrip)
      assert_equal('>test,AALTER,7,3.1.3.3 6.3.2.13,2 2,GO:0000287 GO:0005737,5 5,IPR013221,2', lines.next.rstrip)
      assert_equal('>test,AALER,208,6.1.1.16 2.7.7.38,44 13,GO:0005737 GO:0005524,106 75,IPR014729 IPR009080,48 45', lines.next.rstrip)
      assert_equal('>tost,AALTER,7,3.1.3.3 6.3.2.13,2 2,GO:0000287 GO:0005737,5 5,IPR013221,2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_and_select
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be --batch 2 --select go_term >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_equal('fasta_header,peptide,go_term', lines.next.rstrip)
      assert_equal('>test,AALTER,GO:0000287 GO:0005737', lines.next.rstrip)
      assert_equal('>test,AALER,GO:0005737 GO:0005524', lines.next.rstrip)
      assert_equal('>tost,AALTER,GO:0000287 GO:0005737', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be --batch 2 --format json >test AALTER AALER >tost AALTER])
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
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be --batch 2 --format xml >test AALTER AALER >tost AALTER])
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
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be AKVYSKY])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_empty_and_existing_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be AKVYSKY AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count,ec_number,ec_protein_count,go_term,go_protein_count'))
      assert_equal('AALTER,7,3.1.3.3 6.3.2.13,2 2,GO:0000287 GO:0005737,5 5,IPR013221,2', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_existing_peptide_no_go_terms
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2funct --host http://api.unipept.ugent.be AAEVALVGTEK])
      end
      lines = out.each_line
      assert_equal('', err)
      assert('peptide,total_protein_count', lines.next.rstrip)
      assert_equal('AAEVALVGTEK,0', lines.next.rstrip)
      assert_raises(StopIteration) { lines.next }
    end
  end
end
