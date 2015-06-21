require_relative '../../../lib/commands'

module Unipept
  class UnipeptTaxonomyTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'taxonomy' }
      taxonomy = Commands::Taxonomy.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(100, taxonomy.default_batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(taxonomy -h))
        end
      end
      assert(out.include? 'show help for this command')

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w(taxonomy --help))
        end
      end
      assert(out.include? 'show help for this command')
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w(taxonomy --host http://api.unipept.ugent.be 1))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'taxon_id,taxon_name,taxon_rank')
      assert(lines.next.start_with? '1,root,no rank')
    end

    def test_run_with_fasta_multiple_batches
      out, err = capture_io_while do
        Commands::Unipept.run(%w(taxonomy --host http://api.unipept.ugent.be --batch 2 >test 1 216816 >tost 1))
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'fasta_header,taxon_id,taxon_name,taxon_rank')
      assert(lines.select { |line| line.start_with? '>test,1,' }.size >= 1)
      assert(lines.select { |line| line.start_with? '>test,216816,' }.size >= 1)
      assert(lines.select { |line| line.start_with? '>tost,1,' }.size >= 1)
    end

    def test_run_with_fasta_multiple_batches_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w(taxonomy --host http://api.unipept.ugent.be --batch 2 --format json >test 1 216816 >tost 1))
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
        Commands::Unipept.run(%w(taxonomy --host http://api.unipept.ugent.be --batch 2 --format xml >test 1 216816 >tost 1))
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
