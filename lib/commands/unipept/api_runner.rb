require_relative '../../retryable_typhoeus'

module Unipept
  class Commands::ApiRunner < Cri::CommandRunner
    attr_reader :configuration

    attr_reader :url

    attr_reader :message_url

    attr_reader :user_agent

    def initialize(args, opts, cmd)
      super
      @configuration = Unipept::Configuration.new
      set_configuration

      @url = "#{@host}/api/v1/#{cmd.name}.json"
      @message_url = "#{@host}/api/v1/messages.json"
    end

    # Sets the configurable options of the command line app:
    # - the host
    # - the user agent
    def set_configuration
      @host = host
      @user_agent = 'Unipept CLI - unipept ' + Unipept::VERSION
    end

    # Returns the host. If a value is defined by both an option and the config
    # file, the value of the option is used.
    def host
      # find host in opts first
      host = options[:host] ? options[:host] : @configuration['host']

      # No host has been set?
      if host.nil? || host.empty?
        abort 'WARNING: no host has been set, you can set the host with `unipept config host http://api.unipept.ugent.be/`'
      end

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

    # Returns the default batch_size of a command.
    def batch_size
      100
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

    # Returns an array of regular expressions containing all the selected fields
    def selected_fields
      @selected_fields ||= [*options[:select]].map { |f| f.split(',') }.flatten.map { |f| glob_to_regex(f) }
    end

    # Returns a formatter, based on the format specified in the options
    def formatter
      @formatter ||= Unipept::Formatter.new_for_format(options[:format])
    end

    # Checks if the server has a message and prints it if not empty.
    # We will only check this once a day and won't print anything if the quiet
    # option is set or if we output to a file.
    def print_server_message
      return if options[:quiet]
      return unless $stdout.tty?
      return if recently_fetched?
      @configuration['last_fetch_date'] = Time.now
      @configuration.save
      resp = fetch_server_message
      puts resp unless resp.empty?
    end

    # Fetches a message from the server and returns it
    def fetch_server_message
      Typhoeus.get(@message_url, params: { version: Unipept::VERSION }).body.chomp
    end

    # Returns true if the last check for a server message was less than a day
    # ago.
    def recently_fetched?
      last_fetched = @configuration['last_fetch_date']
      !last_fetched.nil? && (last_fetched + 60 * 60 * 24) > Time.now
    end

    # Returns a new batch_iterator based on the batch_size
    def batch_iterator
      Unipept::BatchIterator.new(batch_size)
    end

    # Runs the command
    def run
      print_server_message
      hydra = Typhoeus::Hydra.new(max_concurrency: 10)
      batch_order = Unipept::BatchOrder.new

      batch_iterator.iterate(input_iterator) do |input_slice, batch_id, fasta_mapper|
        request = ::RetryableTyphoeus::Request.new(
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
        hydra.run if batch_id % 200 == 0
      end

      hydra.run
    end

    # Saves an error to a new file in the .unipept directory in the users home
    # directory.
    def save_error(message)
      path = error_file_path
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') { |f| f.write message }
      $stderr.puts "API request failed! log can be found in #{path}"
    end

    # Write a string to the output defined by the command. If a file is given,
    # write it to the file. If not, write to stdout
    def write_to_output(string)
      if options[:output]
        File.open(options[:output], 'a') { |f| f.write string }
      else
        puts string
      end
    end

    private

    def error_file_path
      File.expand_path(File.join(Dir.home, '.unipept', "unipept-#{Time.now.strftime('%F-%T')}.log"))
    end

    # Handles the response of an API request.
    # Returns a block to execute.
    def handle_response(response, batch_id, fasta_mapper)
      if response.success?
        result = filter_result(response.response_body)

        lambda do
          unless result.empty?
            write_to_output formatter.header(result, fasta_mapper) if batch_id == 0
            write_to_output formatter.format(result, fasta_mapper)
          end
        end
      elsif response.timed_out?
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
