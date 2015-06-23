module Unipept
  class Commands::ApiRunner < Cri::CommandRunner
    attr_reader :configuration

    attr_reader :url

    attr_reader :user_agent

    def initialize(args, opts, cmd)
      super
      @configuration = Unipept::Configuration.new

      @host = host
      @user_agent = 'Unipept CLI - unipept ' + Unipept::VERSION
      @url = "#{@host}/api/v1/#{cmd.name}.json"
    end

    # Returns the host. If a value is defined by both an option and the config
    # file, the value of the option is used.
    def host
      # find host in opts first
      host = options[:host] ? options[:host] : @configuration['host']
      host = 'http://api.unipept.ugent.be' if host.nil? || host.empty?

      # add http:// if needed
      if host.start_with?('http://') || host.start_with?('https://')
        host
      else
        "http://#{host}"
      end
    end

    # Returns an input iterator to use for the request.
    # - if arguments are given, uses arguments
    # - if the input file option is given, uses file input
    # - if none of the previous are given, uses stdin
    def input_iterator
      return arguments.each unless arguments.empty?
      return IO.foreach(options[:input]) if options[:input]
      $stdin.each_line
    end

    def output_writer
      @output_writer ||= OutputWriter.new(options[:output])
    end

    # Returns the default default_batch_size of a command.
    def default_batch_size
      fail NotImplementedError, 'This must be implemented in a subclass.'
    end

    # returns the effective batch_size of a command
    def batch_size
      if options[:batch]
        options[:batch].to_i
      else
        default_batch_size
      end
    end

    # Returns a new batch_iterator based on the batch_size
    def batch_iterator
      Unipept::BatchIterator.new(batch_size)
    end

    def concurrent_requests
      if options[:parallel]
        options[:parallel].to_i
      else
        10
      end
    end

    def queue_size
      concurrent_requests * 20
    end

    # Returns an array of regular expressions containing all the selected fields
    def selected_fields
      @selected_fields ||= [*options[:select]].map { |f| f.split(',') }.flatten.map { |f| glob_to_regex(f) }
    end

    # Returns a formatter, based on the format specified in the options
    def formatter
      @formatter ||= Unipept::Formatter.new_for_format(options[:format])
    end

    # Constructs a request body (a Hash) for set of input strings, using the
    # options supplied by the user.
    def construct_request_body(input)
      names = selected_fields.empty? || selected_fields.any? { |f| f.to_s.include? 'name' }
      { input: input,
        equate_il: options[:equate] == true,
        extra: options[:all] == true,
        names: options[:all] == true && names
      }
    end

    # Runs the command
    def run
      ServerMessage.new(@host).print unless options[:quiet]
      hydra = Typhoeus::Hydra.new(max_concurrency: concurrent_requests)
      batch_order = Unipept::BatchOrder.new
      last_id = 0

      batch_iterator.iterate(input_iterator) do |input_slice, batch_id, fasta_mapper|
        last_id =  batch_id

        request = Typhoeus::Request.new(
          @url,
          method: :post,
          body: construct_request_body(input_slice),
          accept_encoding: 'gzip',
          headers: { 'User-Agent' => @user_agent }
        )

        request.on_complete do |resp|
          block = handle_response(resp, batch_id, fasta_mapper)
          batch_order.wait(batch_id, &block)
        end

        hydra.queue request
        hydra.run if batch_id % queue_size == 0
      end

      hydra.run
      batch_order.wait(last_id + 1) { output_writer.write_line formatter.footer }
    end

    # Saves an error to a new file in the .unipept directory in the users home
    # directory.
    def save_error(message)
      path = error_file_path
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') { |f| f.write message }
      $stderr.puts "API request failed! log can be found in #{path}"
    end

    private

    def error_file_path
      File.expand_path(File.join(Dir.home, '.unipept', "unipept-#{Time.now.strftime('%F-%T')}.log"))
    end

    # Handles the response of an API request.
    # Returns a block to execute.
    def handle_response(response, batch_id, fasta_mapper)
      if response.success?
        handle_success_response(response, batch_id, fasta_mapper)
      else
        handle_failed_response(response)
      end
    end

    def handle_success_response(response, batch_id, fasta_mapper)
      result = filter_result(response.response_body)

      lambda do
        unless result.empty?
          output_writer.write_line formatter.header(result, fasta_mapper) if batch_id == 0
          output_writer.write_line formatter.format(result, fasta_mapper, batch_id == 0)
        end
      end
    end

    def handle_failed_response(response)
      if response.timed_out?
        -> { save_error('request timed out, continuing anyway, but results might be incomplete') }
      elsif response.code == 0
        -> { save_error('could not get an http response, continuing anyway, but results might be incomplete' + response.return_message) }
      else
        -> { save_error("Got #{response.code}: #{response.response_body}\nRequest headers: #{response.request.options}\nRequest body:\n#{response.request.encoded_body}\n\n") }
      end
    end

    # Parses the json_response, wraps it in an array if needed and filters the
    # fields based on the selected_fields
    def filter_result(json_response)
      result = JSON[json_response] rescue []
      result = [result] unless result.is_a? Array
      result.map! { |r| r.select! { |k, _v| selected_fields.any? { |f| f.match k } } } unless selected_fields.empty?
      result
    end

    def glob_to_regex(string)
      /^#{string.gsub('*', '.*')}$/
    end
  end
end
