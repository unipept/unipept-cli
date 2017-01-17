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

    def test_required_fields
      command = Cri::Command.define { name 'pept2lca' }
      pept2lca = Commands::Pept2lca.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['peptide'], pept2lca.required_fields)
    end

    def test_argument_batch_size
      command = Cri::Command.define { name 'pept2lca' }
      pept2lca = Commands::Pept2lca.new({ host: 'http://api.unipept.ugent.be', batch: '123' }, [], command)
      assert_equal(123, pept2lca.batch_size)
    end

    def test_batch_size
      command = Cri::Command.define { name 'pept2lca' }
      pept2lca = Commands::Pept2lca.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(1000, pept2lca.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2lca -h))
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(pept2lca --help))
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2lca --host http://api.unipept.ugent.be AALTER))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('peptide,taxon_id'))
      assert(lines.next.start_with?('AALTER,1,root,no rank'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2lca --host http://api.unipept.ugent.be --batch 2 >test AALTER AALER >tost AALTER))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('fasta_header,peptide,taxon_id'))
      assert(lines.next.start_with?('>test,AALTER,1,root,no rank'))
      assert(lines.next.start_with?('>test,AALER,1,root,no rank'))
      assert(lines.next.start_with?('>tost,AALTER,1,root,no rank'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_and_select
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2lca --host http://api.unipept.ugent.be --batch 2 --select taxon_id >test AALTER AALER >tost AALTER))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('fasta_header,peptide,taxon_id'))
      assert(lines.next.start_with?('>test,AALTER,1'))
      assert(lines.next.start_with?('>test,AALER,1'))
      assert(lines.next.start_with?('>tost,AALTER,1'))
      assert_raises(StopIteration) { lines.next }
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w(pept2lca --host http://api.unipept.ugent.be --batch 2 --format json >test AALTER AALER >tost AALTER))
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
        Commands::Unipept.run(%w(pept2lca --host http://api.unipept.ugent.be --batch 2 --format xml >test AALTER AALER >tost AALTER))
      end
      lines = out.each_line
      assert_equal('', err)
      output = lines.to_a.join('').chomp
      assert(output.start_with?('<results>'))
      assert(output.end_with?('</results>'))
      assert(output.include?('<fasta_header>'))
    end
  end
end
