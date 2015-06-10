require_relative '../../../lib/commands/unipept/api_runner'

module Unipept
  class UnipeptAPIRunnerTestCase < Unipept::TestCase
    def test_init
      runner = new_runner('test', { host: 'test_host' }, %w(a b c))
      assert_equal('test', runner.command.name)
      assert_equal('test_host', runner.options[:host])
      assert_equal(%w(a b c), runner.arguments)
      assert(!runner.configuration.nil?)
      assert_equal('http://test_host/api/v1/test.json', runner.url)
      assert_equal('http://test_host/api/v1/messages.json', runner.message_url)
      assert(/Unipept CLI - unipept [0-9]\.[0-9]\.[0-9]/.match runner.user_agent)
    end

    def test_config_host
      runner = new_runner('test', { host: 'http://param_host' }, %w(a b c))
      runner.options.delete(:host)
      runner.configuration['host'] = 'http://config_host'
      host = runner.get_host
      assert_equal('http://config_host', host)
    end

    def test_param_host
      runner = new_runner('test', { host: 'http://param_host' }, %w(a b c))
      runner.configuration.delete('host')
      host = runner.get_host
      assert_equal('http://param_host', host)
    end

    def test_no_host
      runner = new_runner('test', { host: 'param_host' }, %w(a b c))
      runner.configuration.delete('host')
      runner.options.delete(:host)
      _out, err = capture_io_while do
        assert_raises SystemExit do
          runner.get_host
        end
      end
      assert(err.start_with? 'WARNING: no host has been set')
    end

    def test_host_priority
      runner = new_runner('test', { host: 'http://param_host' }, %w(a b c))
      runner.configuration['host'] = 'http://config_host'
      host = runner.get_host
      assert_equal('http://param_host', host)
    end

    def test_http_host
      runner = new_runner('test', { host: 'param_host' }, %w(a b c))
      host = runner.get_host
      assert_equal('http://param_host', host)
    end

    def test_https_host
      runner = new_runner('test', { host: 'https://param_host' }, %w(a b c))
      host = runner.get_host
      assert_equal('https://param_host', host)
    end

    def test_input_iterator_args
      runner = new_runner('test', { host: 'https://param_host' }, %w(a b c))
      output = []
      runner.input_iterator.each { |el| output << el.chomp }
      assert_equal(%w(a b c), output)
    end

    def test_input_iterator_file
      File.open('input_file', 'w') { |file| file.write(%w(a b c).join("\n")) }
      runner = new_runner('test',  host: 'https://param_host', input: 'input_file')
      output = []
      runner.input_iterator.each { |el| output << el.chomp }
      assert_equal(%w(a b c), output)
    end

    def test_input_iterator_stdin
      runner = new_runner('test',  host: 'https://param_host')
      output = []
      _out, _err = capture_io_with_input(%w(a b c)) do
        runner.input_iterator.each { |el| output << el.chomp }
      end
      assert_equal(%w(a b c), output)
    end

    def test_input_iterator_arguments_priority
      File.open('input_file', 'w') { |file| file.write(%w(1 2 3).join("\n")) }
      runner = new_runner('test', { host: 'https://param_host', input: 'input_file' }, %w(a b c))
      output = []
      _out, _err = capture_io_with_input(%w(1 2 3)) do
        runner.input_iterator.each { |el| output << el.chomp }
      end
      assert_equal(%w(a b c), output)
    end

    def test_input_iterator_file_priority
      File.open('input_file', 'w') { |file| file.write(%w(a b c).join("\n")) }
      runner = new_runner('test',  host: 'https://param_host', input: 'input_file')
      output = []
      _out, _err = capture_io_with_input(%w(1 2 3)) do
        runner.input_iterator.each { |el| output << el.chomp }
      end
      assert_equal(%w(a b c), output)
    end

    def new_runner(command_name = 'test', options = { host: 'http://param_host' }, arguments = [])
      command = Cri::Command.define { name command_name }
      Commands::ApiRunner.new(options, arguments, command)
    end
  end
end
