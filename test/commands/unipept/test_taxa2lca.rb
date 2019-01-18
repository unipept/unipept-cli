require_relative '../../../lib/commands'

module Unipept
  class UnipeptTaxa2lcaTestCase < Unipept::TestCase
    def test_default_batch_size
      command = Cri::Command.define { name 'taxa2lca' }
      taxa2lca = Commands::Taxa2lca.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_raises RuntimeError do
        taxa2lca.default_batch_size
      end
    end

    def test_required_fields
      command = Cri::Command.define { name 'taxa2lca' }
      taxa2lca = Commands::Taxa2lca.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal([], taxa2lca.required_fields)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[taxa2lca -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[taxa2lca --help])
        end
      end
      assert(out.include?('show help for this command'))
    end

    def test_run
      out, err = capture_io_while do
        Commands::Unipept.run(%w[taxa2lca --host http://api.unipept.ugent.be 216816 1680])
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with?('taxon_id,taxon_name,taxon_rank'))
      assert(lines.next.start_with?('1678,Bifidobacterium,genus'))
    end

    def test_run_xml
      out, err = capture_io_while do
        Commands::Unipept.run(%w[taxa2lca --host http://api.unipept.ugent.be --format xml 216816 1680])
      end
      lines = out.each_line
      output = lines.to_a.join('').chomp
      assert_equal('', err)
      assert(output.start_with?('<results>'))
      assert(output.end_with?('</results>'))
    end

    def test_run_json
      out, err = capture_io_while do
        Commands::Unipept.run(%w[taxa2lca --host http://api.unipept.ugent.be --format json 216816 1680])
      end
      lines = out.each_line
      output = lines.to_a.join('').chomp
      assert_equal('', err)
      assert(output.start_with?('['))
      assert(output.end_with?(']'))
      assert(!output.include?('}{'))
      assert(!output.include?(']['))
    end
  end
end
