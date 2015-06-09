require 'set'

module Unipept
  class Commands::ApiRunner < Cri::CommandRunner
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
      @host = get_host
      @user_agent = 'Unipept CLI - unipept ' + Unipept::VERSION
    end

    # Returns the host. If a value is defined by both an option and the config
    # file, the value of the option is used.
    def get_host
      # find host in opts first
      host = options[:host] ? options[:host] : @configuration['host']

      # No host has been set?
      if host.nil? || host.empty?
        abort 'WARNING: no host has been set, you can set the host with `unipept config host http://api.unipept.ugent.be:3000/`'
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
    def get_input_iterator
      return arguments.each unless arguments.empty?
      return IO.foreach(options[:input]) if options[:input]
      STDIN.each_line
    end

    # Returns the default batch_size of a command.
    def batch_size
      100
    end

    # Constructs a request body (a Hash) for set of input strings, using the
    # options supplied by the user.
    def get_request_body(input, selected_fields)
      names = selected_fields.empty? || selected_fields.any? { |f| /.*name.*/.match f }
      { input: input,
        equate_il: options[:equate],
        extra: options[:all],
        names: options[:all] && names
      }
    end

    # Checks if the server has a message and prints it if not empty.
    # We will only check this once a day and won't print anything if the quiet
    # option is set or if we output to a file.
    def print_server_message
      return if options[:quiet]
      return unless STDOUT.tty?
      return if recently_fetched?
      @configuration['last_fetch_date'] = Time.now
      @configuration.save
      resp = Typhoeus.get(@message_url, params: { version: Unipept::VERSION }).body.chomp
      puts resp unless resp.empty?
    end

    # Returns true if the last check for a server message was less than a day
    # ago.
    def recently_fetched?
      last_fetched = @configuration['last_fetch_date']
      !last_fetched.nil? && (last_fetched + 60 * 60 * 24) > Time.now
    end

    def run
      print_server_message
      hydra = Typhoeus::Hydra.new(max_concurrency: 10)
      formatter = Unipept::Formatter.new_for_format(options[:format])
      batch_order = Unipept::BatchOrder.new

      input = get_input_iterator
      selected_fields = options[:select] ? options[:select] : []
      selected_fields = selected_fields.map { |f| f.include?(',') ? f.split(',') : f }.flatten.map { |f| glob_to_regex(f) }

      line_iterator(input) do |input_slice, batch_id, fasta_input|
        request = Typhoeus::Request.new(
          @url,
          method: :post,
          body: get_request_body(input_slice, selected_fields),
          accept_encoding: 'gzip',
          headers: { 'User-Agent' => @user_agent }
        )
        request.on_complete do |resp|
          if resp.success?
            result = JSON[resp.response_body] rescue []
            result = [result] unless result.is_a? Array
            result.map! { |r| r.select! { |k, _v| selected_fields.any? { |f| f.match k } } } unless selected_fields.empty?

            # wait till it's our turn to write
            batch_order.wait(batch_id) do
              unless result.empty?
                write_to_output formatter.header(result, fasta_input) if batch_id == 0
                write_to_output formatter.format(result, fasta_input)
              end
            end

          elsif resp.timed_out?
            batch_order.wait(batch_id) do
              $stderr.puts 'request timed out, continuing anyway, but results might be incomplete'
              save_error('request timed out, continuing anyway, but results might be incomplete')
            end
          elsif resp.code == 0
            batch_order.wait(batch_id) do
              $stderr.puts 'could not get an http response, continuing anyway, but results might be incomplete'
              save_error(resp.return_message)
            end
          else
            batch_order.wait(batch_id) do
              $stderr.puts "received a non-successful http response #{resp.code}, continuing anyway, but results might be incomplete"
              save_error("Got #{resp.code}: #{resp.response_body}\nRequest headers: #{resp.request.options}\nRequest body:\n#{resp.request.encoded_body}\n\n")
            end
          end
        end

        hydra.queue request

        if batch_id % 200 == 0
          hydra.run
        end
      end

      hydra.run
    end

    def save_error(message)
      path = File.expand_path(File.join(Dir.home, '.unipept', "unipept-#{Time.now.strftime('%F-%T')}.log"))
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') do |f|
        f.write message
      end
      $stderr.puts "API request failed! log can be found in #{path}"
    end

    def write_to_output(string)
      if options[:output]
        File.open(options[:output], 'a') do |f|
          f.write string
        end
      else
        puts string
      end
    end

    def line_iterator(lines, &block)
      first_line = lines.next rescue return
      if first_line.start_with? '>'
        current_fasta_header = first_line.chomp
        lines.each_slice(batch_size).with_index do |slice, i|
          fasta_mapper = []
          input_set = Set.new

          slice.each do |line|
            line.chomp!
            if line.start_with? '>'
              current_fasta_header = line
            else
              fasta_mapper << [current_fasta_header, line]
              input_set << line
            end
          end

          block.call(input_set.to_a, i, fasta_mapper)
        end
      else
        Enumerator.new do |y|
          y << first
          loop do
            y << lines.next
          end
        end.each_slice(batch_size).with_index(&block)

      end
    end

    private

    def glob_to_regex(string)
      /^#{string.gsub('*', '.*')}$/
    end
  end
end
