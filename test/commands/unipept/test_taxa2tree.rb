require_relative '../../../lib/commands'

module Unipept
  class UnipeptTaxa2TreeTestCase < Unipept::TestCase
    def test_required_fields
      command = Cri::Command.define { name 'taxa2tree' }
      taxa2tree = Commands::Taxa2Tree.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(['taxon_id'], taxa2tree.required_fields)
    end

    def test_batch_size
      command = Cri::Command.define { name 'taxa2tree' }
      taxa2tree = Commands::Taxa2Tree.new({ host: 'http://api.unipept.ugent.be' }, [], command)
      assert_equal(0, taxa2tree.batch_size)
    end

    def test_help
      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[taxa2tree -h])
        end
      end
      assert(out.include?('show help for this command'))

      out, _err = capture_io_while do
        assert_raises SystemExit do
          Commands::Unipept.run(%w[taxa2tre --help])
        end
      end
      assert(out.include?('show help for this command'))
    end
  end

  def test_run
    out, err = capture_io_while do
      Commands::Unipept.run(%w[taxa2tree --host http://api.unipept.ugent.be 78 57 89 28 67])
    end
    lines = out.each_line
    output = lines.to_a.join('').chomp
    assert_equal('', err)

    assert(output.start_with?('{'))
    assert(output.end_with?('}'))
    assert(output.include?('Bacteria'))
    assert(output.include?('superkingdom'))
  end

  def test_run_url
    out, err = capture_io_while do
      Commands::Unipept.run(%w[taxa2tree --host http://api.unipept.ugent.be --format url 78 57 89 28 67])
    end
    lines = out.each_line
    assert_equal('', err)
    assert_equal('https://bl.ocks.org/8837824df7ef9831a9b4216f3fb547ee', lines.next.rstrip)
  end

  def test_run_html
    out, err = capture_io_while do
      Commands::Unipept.run(%w[taxa2tree --host http://api.unipept.ugent.be --format html 78 57 89 28 67])
    end
    lines = out.each_line
    assert_equal('', err)
    output = lines.to_a.join('').chomp
    assert(output.start_with?('<!DOCTYPE html>'))
    assert(output.end_with?('</html>'))
    assert(output.include?('</body>'))
  end
end
