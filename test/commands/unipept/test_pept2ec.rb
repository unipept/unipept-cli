require_relative '../../../lib/commands'

module Unipept
  class UnipeptPept2ecTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'pept2ec' }
      pept2ec = Commands::Pept2ec.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2ec.default_batch_size)
      pept2ec.options[:all] = true
      assert_equal(100, pept2ec.default_batch_size)
    end

    def test_required_fields
      command = Cri::Command.define { name 'pept2ec' }
      pept2ec = Commands::Pept2ec.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], pept2ec.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'pept2ec' }
      pept2ec = Commands::Pept2ec.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2ec.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'pept2ec' }
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

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count,ec_number,ec_protein_count'))
      assert(lines.next.start_with?('AALTER,7,3.1.3.3 6.3.2.13,2 2'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be --batch 2 >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('fasta_header,peptide,total_protein_count,ec_number,ec_protein_count'))
      assert(lines.next.start_with?('>test,AALTER,7,3.1.3.3 6.3.2.13,2 2'))
      assert(lines.next.start_with?('>test,AALER,208,6.1.1.16 2.7.7.38,44 13'))
      assert(lines.next.start_with?('>tost,AALTER,7,3.1.3.3 6.3.2.13,2 2'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_and_select
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be --batch 2 --select ec_number >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('fasta_header,peptide,ec_number'))
      assert(lines.next.start_with?('>test,AALTER,3.1.3.3 6.3.2.13'))
      assert(lines.next.start_with?('>test,AALER,6.1.1.16 2.7.7.38'))
      assert(lines.next.start_with?('>tost,AALTER,3.1.3.3 6.3.2.13'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be --batch 2 --format json >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join.chomp
      assert(output.start_with?('['))
      assert(output.end_with?(']'))
      assert(!output.include?('}{'))
      assert(output.include?('fasta_header'))
    end

    def test_run_with_fasta_multiple_batches_xml
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be --batch 2 --format xml >test AALTER AALER >tost AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join.chomp
      assert(output.start_with?('<results>'))
      assert(output.end_with?('</results>'))
      assert(output.include?('<fasta_header>'))
    end

    def test_run_with_empty_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be AKVYSKY])
      end
      lines = out.each_line
      assert_equal('', err)
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_empty_and_existing_peptide
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be AKVYSKY AALTER])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count,ec_number,ec_protein_count'))
      assert(lines.next.start_with?('AALTER,7,3.1.3.3 6.3.2.13,2 2'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_existing_peptide_no_ec_numbers
      out, err = capture_io_while do
        Commands::Unipept.run(%w[pept2ec --host http://api.unipept.ugent.be MDGTEYIIVK])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,total_protein_count'))
      assert(lines.next.start_with?('MDGTEYIIVK,35'))
      assert_raises(StopIteration) { lines.next }
    end
  end
end
