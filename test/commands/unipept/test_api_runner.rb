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

    def test_batch_size
      assert_equal(100, new_runner.batch_size)
    end

    def test_default_formatter
      runner = new_runner
      assert_equal('csv', runner.formatter.type)
    end

    def test_param_formatter
      runner = new_runner('test',  host: 'http://param_host', format: 'json')
      assert_equal('json', runner.formatter.type)
    end

    def test_no_selected_fields
      runner = new_runner
      assert_equal([], runner.selected_fields)
    end

    def test_single_selected_fields
      runner = new_runner('test',  host: 'http://param_host', select: 'field')
      assert_equal([/^field$/], runner.selected_fields)
    end

    def test_comma_selected_fields
      runner = new_runner('test',  host: 'http://param_host', select: 'field1,field2')
      assert_equal([/^field1$/, /^field2$/], runner.selected_fields)
    end

    def test_multiple_selected_fields
      runner = new_runner('test',  host: 'http://param_host', select: %w(field1 field2))
      assert_equal([/^field1$/, /^field2$/], runner.selected_fields)
    end

    def test_combined_selected_fields
      runner = new_runner('test',  host: 'http://param_host', select: ['field1', 'field2,field3'])
      assert_equal([/^field1$/, /^field2$/, /^field3$/], runner.selected_fields)
    end

    def test_wildcard_selected_fields
      runner = new_runner('test',  host: 'http://param_host', select: 'field*')
      assert_equal([/^field.*$/], runner.selected_fields)
    end

    def test_never_recently_fetched
      runner = new_runner
      runner.configuration.delete('last_fetch_date')
      assert(!runner.recently_fetched?)
    end

    def test_old_recently_fetched
      runner = new_runner
      runner.configuration['last_fetch_date'] = Time.now - 60 * 60 * 25
      assert(!runner.recently_fetched?)
    end

    def test_recently_recently_fetched
      runner = new_runner
      runner.configuration['last_fetch_date'] = Time.now - 60 * 60 * 1
      assert(runner.recently_fetched?)
    end

    def test_basic_construct_request_body
      runner = new_runner('test',  host: 'http://param_host')
      body = runner.construct_request_body('test')
      assert_equal('test', body[:input])
      assert_equal(false, body[:equate_il])
      assert_equal(false, body[:extra])
      assert_equal(false, body[:names])
    end

    def test_equate_construct_request_body
      runner = new_runner('test',  host: 'http://param_host', equate: true)
      body = runner.construct_request_body('test')
      assert_equal('test', body[:input])
      assert_equal(true, body[:equate_il])
      assert_equal(false, body[:extra])
      assert_equal(false, body[:names])
    end

    def test_all_no_select_construct_request_body
      runner = new_runner('test',  host: 'http://param_host', all: true)
      body = runner.construct_request_body('test')
      assert_equal('test', body[:input])
      assert_equal(false, body[:equate_il])
      assert_equal(true, body[:extra])
      assert_equal(true, body[:names])
    end

    def test_all_names_select_construct_request_body
      runner = new_runner('test',  host: 'http://param_host', all: true, select: 'test,names')
      body = runner.construct_request_body('test')
      assert_equal('test', body[:input])
      assert_equal(false, body[:equate_il])
      assert_equal(true, body[:extra])
      assert_equal(true, body[:names])
    end

    def test_all_no_names_select_construct_request_body
      runner = new_runner('test',  host: 'http://param_host', all: true, select: 'test')
      body = runner.construct_request_body('test')
      assert_equal('test', body[:input])
      assert_equal(false, body[:equate_il])
      assert_equal(true, body[:extra])
      assert_equal(false, body[:names])
    end

    def test_print_server_message
      runner = new_runner
      runner.stub(:recently_fetched?, false) do
        runner.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            runner.print_server_message
          end
          assert_equal('message', out.chomp)
        end
      end
    end

    def test_quiet_print_server_message
      runner = new_runner('test', host: 'bla', quiet: true)
      runner.stub(:recently_fetched?, false) do
        runner.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            runner.print_server_message
          end
          assert_equal('', out)
        end
      end
    end

    def test_no_tty_print_server_message
      runner = new_runner
      runner.stub(:recently_fetched?, false) do
        runner.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              false
            end
            runner.print_server_message
          end
          assert_equal('', out)
        end
      end
    end

    def test_recent_print_server_message
      runner = new_runner
      runner.stub(:recently_fetched?, true) do
        runner.stub(:fetch_server_message, 'message') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            runner.print_server_message
          end
          assert_equal('', out)
        end
      end
    end

    def test_empty_print_server_message
      runner = new_runner
      runner.stub(:recently_fetched?, false) do
        runner.stub(:fetch_server_message, '') do
          out, _err = capture_io_while do
            def $stdout.tty?
              true
            end
            runner.print_server_message
          end
          assert_equal('', out)
        end
      end
    end

    def test_fetch_server_message
      runner = new_runner('test', host: 'http://api.unipept.ugent.be')
      assert(!runner.fetch_server_message.nil?)
    end

    def new_runner(command_name = 'test', options = { host: 'http://param_host' }, arguments = [])
      command = Cri::Command.define { name command_name }
      Commands::ApiRunner.new(options, arguments, command)
    end
  end
end
