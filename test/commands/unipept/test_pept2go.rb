require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2goTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2go' }
      pept2go = Commands::Pept2go.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2go.default_batch_size)
      pept2go.options[:all] = true
      assert_equal(100, pept2go.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'pept2go' }
      pept2go = Commands::Pept2go.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], pept2go.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'pept2go' }
      pept2go = Commands::Pept2go.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2go.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'pept2go' }
      pept2go = Commands::Pept2go.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2go.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2go -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[pept2go --help])
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count,go_term,go_protein_count'))
      assert(lines.next.start_with?('AALTER,7,GO:0000287 GO:0005737 GO:0042803,5 5 1'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be --batch 2 >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('fasta_header,peptide,total_protein_count,go_term,go_protein_count'))
      assert(lines.next.start_with?('>test,AALTER,7,GO:0000287 GO:0005737 GO:0042803,5 5 1'))
      assert(lines.next.start_with?('>test,AALER,208,GO:0005737 GO:0005524 GO:0008270,106 75 48'))
      assert(lines.next.start_with?('>tost,AALTER,7,GO:0000287 GO:0005737 GO:0042803,5 5 1'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_and_select
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be --batch 2 --select go_term >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('fasta_header,peptide,go_term'))
      assert(lines.next.start_with?('>test,AALTER,GO:0000287 GO:0005737 GO:0042803'))
      assert(lines.next.start_with?('>test,AALER,GO:0005737 GO:0005524 GO:0008270'))
      assert(lines.next.start_with?('>tost,AALTER,GO:0000287 GO:0005737 GO:0042803'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be --batch 2 --format json >test AALTER AALER >tost AALTER])
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
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be --batch 2 --format xml >test AALTER AALER >tost AALTER])
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
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be AKVYSKY])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_empty_and_existing_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be AKVYSKY AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count,go_term,go_protein_count'))
      assert(lines.next.start_with?('AALTER,7,GO:0000287 GO:0005737 GO:0042803,5 5 1'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_existing_peptide_no_go_terms
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2go --host http://api.unipept.ugent.be AAEVALVGTEK])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count'))
      assert(lines.next.start_with?('AAEVALVGTEK,0'))
      assert_raises(StopIteration) { lines.next }
    end
  end
end
