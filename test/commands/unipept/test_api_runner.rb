require_relative '../../../lib/commands/unipept/api_runner'

module Unipept
  # make methods public to test them
  class Commands::ApiRunner
    public :glob_to_regex, :handle_response, :error_file_path, :filter_result
  end

  class UnipeptAPIRunnerTestCase < Unipept::TestCase
    def test_init
      runner = new_runner('test', { host: 'test_host' }, %w(a b c))
      assert_equal('test', runner.command.name)
      assert_equal('test_host', runner.options[:host])
      assert_equal(%w(a b c), runner.arguments)
      assert(!runner.configuration.nil?)
      assert_equal('http://test_host/api/v1/test.json', runner.url)
      assert(/Unipept CLI - unipept [0-9]*\.[0-9]*\.[0-9]*/.match runner.user_agent)
    end

    def test_config_host
      runner = new_runner('test', { host: 'http://param_host' }, %w(a b c))
      runner.options.delete(:host)
      runner.configuration['host'] = 'http://config_host'
      host = runner.host
      assert_equal('http://config_host', host)
    end

    def test_param_host
      runner = new_runner('test', { host: 'http://param_host' }, %w(a b c))
      runner.configuration.delete('host')
      host = runner.host
      assert_equal('http://param_host', host)
    end

    def test_no_host
      runner = new_runner('test', { host: 'param_host' }, %w(a b c))
      runner.configuration.delete('host')
      runner.options.delete(:host)
      host = runner.host
      assert_equal('http://api.unipept.ugent.be', host)
    end

    def test_host_priority
      runner = new_runner('test', { host: 'http://param_host' }, %w(a b c))
      runner.configuration['host'] = 'http://config_host'
      host = runner.host
      assert_equal('http://param_host', host)
    end

    def test_http_host
      runner = new_runner('test', { host: 'param_host' }, %w(a b c))
      host = runner.host
      assert_equal('http://param_host', host)
    end

    def test_https_host
      runner = new_runner('test', { host: 'https://param_host' }, %w(a b c))
      host = runner.host
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

    def test_required_fields
      assert_equal([], new_runner.required_fields)
    end

    def test_required_fields_configurable
      r = new_runner
      def r.required_fields
        ['test']
      end
      assert_equal(['test'], r.required_fields)
    end

    def test_default_batch_size
      assert_raises NotImplementedError do
        new_runner.default_batch_size
      end
    end

    def test_batch_size
      r = new_runner
      def r.default_batch_size
        100
      end
      assert_equal(100, r.batch_size)
    end

    def test_argument_batch_size
      runner = new_runner('test',  host: 'http://param_host', batch: '123')
      assert_equal(123, runner.batch_size)
    end

    def test_number_of_parallel_requests
      assert_equal(10, new_runner.concurrent_requests)
      runner = new_runner('test',  host: 'http://param_host', parallel: '123')
      assert_equal(123, runner.concurrent_requests)
    end

    def test_queue_size
      assert_equal(200, new_runner.queue_size)
      runner = new_runner('test',  host: 'http://param_host', parallel: '100')
      assert_equal(2000, runner.queue_size)
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

    def test_required_fields_are_not_selected_with_empty_selection
      runner = new_runner
      def runner.required_fields
        ['test']
      end
      assert_equal([], runner.selected_fields)
    end

    def test_required_fields_are_selected
      runner = new_runner('test',  host: 'http://param_host', select: 'field')
      def runner.required_fields
        ['test']
      end
      assert_equal([/^field$/, /^test$/], runner.selected_fields)
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

    def test_all_names_wildcard_select_construct_request_body
      runner = new_runner('test',  host: 'http://param_host', all: true, select: 'test,order*')
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

    def test_glob_to_regex
      runner = new_runner
      assert(/^simple$/, runner.glob_to_regex('simple'))
      assert(/^.*simple.*$/, runner.glob_to_regex('*simple*'))
    end

    def test_save_error
      runner = new_runner
      runner.stub(:error_file_path, 'errordir/error.log') do
        _out, err = capture_io_while do
          runner.save_error('error message')
        end
        assert(err.start_with? 'API request failed! log can be found in')
        assert_equal('error message', IO.foreach('errordir/error.log').next.chomp)
      end
    end

    def test_error_file_path
      runner = new_runner
      assert(runner.error_file_path.include? '/.unipept/')
    end

    def test_invalid_filter_result
      runner = new_runner
      assert_equal([], runner.filter_result('{"key":"value'))
    end

    def test_array_wrap_filter_result
      runner = new_runner
      assert_equal([{ 'key' => 'value' }], runner.filter_result('{"key":"value"}'))
    end

    def test_filter_filter_result
      runner = new_runner('test', host: 'test', select: 'key1')
      result = runner.filter_result('[{"key1":"value1","key2":"value1"},{"key1":"value2","key2":"value2"}]')
      assert_equal([{ 'key1' => 'value1' }, { 'key1' => 'value2' }], result)
    end

    def test_success_header_handle_response
      runner = new_runner
      response = new_response(success: true, response_body: '[{"key1":"value1","key2":"value1"},{"key1":"value2","key2":"value2"}]')
      lambda = runner.handle_response(response, 0, nil)
      assert(lambda.lambda?)
      out, err = capture_io_while(&lambda)
      lines = out.each_line
      assert_equal('', err)
      assert_equal('key1,key2', lines.next.chomp)
      assert_equal('value1,value1', lines.next.chomp)
      assert_equal('value2,value2', lines.next.chomp)
    end

    def test_success_no_header_handle_response
      runner = new_runner
      response = new_response(success: true, response_body: '[{"key1":"value1","key2":"value1"},{"key1":"value2","key2":"value2"}]')
      lambda = runner.handle_response(response, 1, nil)
      assert(lambda.lambda?)
      out, err = capture_io_while(&lambda)
      lines = out.each_line
      assert_equal('', err)
      assert_equal('value1,value1', lines.next.chomp)
      assert_equal('value2,value2', lines.next.chomp)
    end

    def test_time_out_handle_response
      runner = new_runner
      response = new_response(success: false, timed_out: true)
      lambda = runner.handle_response(response, 0, nil)
      assert(lambda.lambda?)
      def runner.save_error(input)
        $stderr.puts(input)
      end
      out, err = capture_io_while(&lambda)
      assert_equal('', out)
      assert(err.chomp.start_with? 'request timed out')
    end

    def test_code_0_handle_response
      runner = new_runner
      response = new_response(success: false, timed_out: false, code: 0)
      lambda = runner.handle_response(response, 0, nil)
      assert(lambda.lambda?)
      def runner.save_error(input)
        $stderr.puts(input)
      end
      out, err = capture_io_while(&lambda)
      assert_equal('', out)
      assert(err.chomp.start_with? 'could not get an http')
    end

    def test_failed_handle_response
      runner = new_runner
      response = new_response(success: false, timed_out: false, code: 10)
      lambda = runner.handle_response(response, 0, nil)
      assert(lambda.lambda?)
      def runner.save_error(input)
        $stderr.puts(input)
      end
      out, err = capture_io_while(&lambda)
      assert_equal('', out)
      assert(err.chomp.start_with? 'Got 10')
    end

    def test_run
      runner = new_runner('taxonomy', host: 'http://api.unipept.ugent.be')
      out, err = capture_io_while do
        def runner.input_iterator
          %w(0 1 2).each
        end
        def runner.batch_size
          2
        end
        runner.run
      end
      lines = out.each_line
      assert_equal('', err)
      assert(lines.next.start_with? 'taxon_id')
      assert(lines.next.start_with? '1,root')
      assert(lines.next.start_with? '2,Bacteria')
      assert_raises(StopIteration) { lines.next }
    end

    def new_runner(command_name = 'test', options = { host: 'http://param_host' }, arguments = [])
      command = Cri::Command.define { name command_name }
      Commands::ApiRunner.new(options, arguments, command)
    end

    def new_response(values)
      response = Class.new do
        def initialize(values)
          @values = values
        end

        def success?
          @values[:success]
        end

        def timed_out?
          @values[:timed_out]
        end

        def code
          @values[:code]
        end

        def response_body
          @values[:response_body]
        end

        def return_message
          ''
        end

        def request
          o = Object.new
          def o.options
            ''
          end
          def o.encoded_body
            ''
          end
          o
        end
      end
      response.new(values)
    end
  end
end
