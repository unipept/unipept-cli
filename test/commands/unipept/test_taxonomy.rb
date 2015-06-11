require_relative '../../../lib/commands'

module Unipept
  class UnipeptTaxonomyTestCase < Unipept::TestCase
    def test_batch_size
      command = Cri::Command.define { name 'taxonomy' }
      taxonomy = Commands::Taxonomy.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(100, taxonomy.batch_size)
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
  end
end
