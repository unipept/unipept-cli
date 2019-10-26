require_relative '../../retryable_typhoeus'

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
      @fasta = false
    end

    # Returns the host. If a value is defined by both an option and the config
    # file, the value of the option is used.
    def host
      # find host in opts first
      host = options[:host] || @configuration['host']
      host = 'http://api.unipept.ugent.be' if host.nil? || host.empty?

      # add http:// if needed
      if host.start_with?('http://', 'https://')
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
      raise NotImplementedError, 'This must be implemented in a subclass.'
    end

    # returns the effective batch_size of a command
    def batch_size
      if options[:batch]
        options[:batch].to_i
      else
        default_batch_size
      end
    end

    # returns the required fields to do any mapping
    def required_fields
      []
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
      return @selected_fields unless @selected_fields.nil?

      fields = [*options[:select]].map { |f| f.split(',') }.flatten
      fields.concat(required_fields) unless fields.empty?
      @selected_fields = fields.map { |f| glob_to_regex(f) }
    end

    # Returns a formatter, based on the format specified in the options
    def formatter
      @formatter ||= Unipept::Formatter.new_for_format(options[:format])
    end

    # Constructs a request body (a Hash) for set of input strings, using the
    # options supplied by the user.
    def construct_request_body(input)
      names = selected_fields.empty? || selected_fields.any? { |f| f.to_s.include?('name') || f.to_s.include?('.*$') }
      { input: input,
        equate_il: options[:equate] == true,
        extra: options[:all] == true,
        names: options[:all] == true && names }
    end

    # Runs the command
    def run
      ServerMessage.new(@host).print unless options[:quiet]
      hydra = Typhoeus::Hydra.new(max_concurrency: concurrent_requests)
      batch_order = Unipept::BatchOrder.new
      last_id = 0

      batch_iterator.iterate(input_iterator) do |input_slice, batch_id, fasta_mapper|
        last_id = batch_id
        @fasta = !fasta_mapper.nil?
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
        hydra.run if (batch_id % queue_size).zero?
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
      warn "API request failed! log can be found in #{path}"
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
          output_writer.write_line formatter.header(result, fasta_mapper) if batch_id.zero? && !options[:"no-header"]
          output_writer.write_line formatter.format(result, fasta_mapper, batch_id.zero?)
        end
      end
    end

    def handle_failed_response(response)
      if response.timed_out?
        -> { save_error('request timed out, continuing anyway, but results might be incomplete') }
      elsif response.code.zero?
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
      key_order = result.first.keys if result.first
      result = flatten_functional_fields(result) if formatter.instance_of?(Unipept::CSVFormatter)
      result.map! { |r| r.select! { |k, _v| selected_fields.any? { |f| f.match k } } } unless selected_fields.empty?
      result = inflate_functional_fields(result, key_order) if formatter.instance_of?(Unipept::CSVFormatter) && result.first
      result
    end

    # Transforms the hierarchical input to something without hierarchy. All fields
    # associated with functional annotations are transformed to a flat alternative.
    # Example: {"go" => {"go_term": xxx, "protein_count": yyy}} --> {"go_term" => [xxx], "protein_count" => [yyy]}
    def flatten_functional_fields(data)
      output = []
      data.each do |row|
        output_row = {}
        row.each do |k, v|
          if %w[ec go].include? k
            v.each do |item|
              item.each do |field_name, field_value|
                new_field_name = %w[ec_number go_term].include?(field_name) ? field_name : k + '_' + field_name
                output_row[new_field_name] = [] unless output_row.key? new_field_name
                output_row[new_field_name] << field_value
              end
            end
          else
            output_row[k] = v
          end
        end
        output << output_row
      end
      output
    end

    # Transforms a flattened input created by flatten_functional_fields to the original
    # hierarchy.
    def inflate_functional_fields(data, original_key_order)
      output = []
      data.each do |row|
        output_row = {}

        processed_keys = []
        original_key_order.each do |original_key|
          if %w[ec go].include? original_key
            # First, we take all distinct keys that start with "ec" or "go"
            annotation_keys = row.keys.select { |key| key.start_with? original_key }
            processed_keys += annotation_keys
            unless annotation_keys.empty?
              # Each of the values of the annotation_keys is an array. All respective values of each of
              # these arrays need to be put together into one hash. (E.g. {a => [1, 2], b=> [x, y]} --> [{a: 1, b: x}, {a: 2, b: y}])
              reconstructed_objects = []
              (0..annotation_keys[0].length).each do |i|
                reconstructed_object = {}
                annotation_keys.each do |annotation_key|
                  reconstructed_object[%w[ec_number go_term].include?(annotation_key) ? annotation_key : annotation_key[3, annotation_key.length]] = row[annotation_key][i]
                end
                reconstructed_objects << reconstructed_object
              end
              output_row[original_key] = reconstructed_objects
            end
          elsif row.key? original_key
            output_row[original_key] = row[original_key]
          end
        end

        output << output_row
      end
      output
    end

    def glob_to_regex(string)
      /^#{string.gsub('*', '.*')}$/
    end
  end
end
