require 'set'

module Unipept::Commands
  class ApiRunner < Cri::CommandRunner
    def initialize(args, opts, cmd)
      super
      @configuration = Unipept::Configuration.new
      set_configuration

      @user_agent = 'Unipept CLI - unipept ' + Unipept::VERSION

      @url = "#{@host}/api/v1/#{cmd.name}.json"
      @message_url = "#{@host}/api/v1/messages.json"
    end

    def set_configuration
      # find host in opts first
      if options[:host]
        host = options[:host]
      else
        host = @configuration['host']
      end

      # No host has been set?
      if host.nil? || host.empty?
        puts 'WARNING: no host has been set, you can set the host with `unipept config host http://localhost:3000/`'
        exit 1
      end
      unless host.start_with? 'http://'
        host = "http://#{host}"
      end

      @host = host
    end

    def input_iterator
      # Argument over file input over stdin
      if !arguments.empty?
        arguments.each
      else
        if options[:input]
          IO.foreach(options[:input])
        else
          STDIN.each_line
        end
      end
    end

    def batch_size
      100
    end

    def url_options(sub_part)
      filter = options[:select] ? options[:select] : []
      if filter.empty?
        names = true
      else
        names = filter.any? { |f| /.*name.*/.match f }
      end
      { input: sub_part,
        equate_il: options[:equate],
        extra: options[:all],
        names: names
      }
    end

    def get_server_message
      return if options[:quiet]
      return unless STDOUT.tty?
      last_fetched = @configuration['last_fetch_date']
      return unless last_fetched.nil? || (last_fetched + 60 * 60 * 24) < Time.now
      version = Unipept::VERSION
      resp = Typhoeus.get(@message_url, params: { version: version })
      puts resp.body unless resp.body.chomp.empty?
      @configuration['last_fetch_date'] = Time.now
      @configuration.save
    end

    def run
      get_server_message

      formatter = Unipept::Formatter.new_for_format(options[:format])
      peptides = input_iterator

      filter_list = options[:select] ? options[:select] : []
      # Parse filter list: convert to regex and split on commas
      filter_list = filter_list.map { |f| f.include?(',') ? f.split(',') : f }.flatten.map { |f| glob_to_regex(f) }

      batch_order = Unipept::BatchOrder.new

      printed_header = false
      result = []

      hydra = Typhoeus::Hydra.new(max_concurrency: 10)
      num_req = 0

      peptide_iterator(peptides) do |sub_division, i, fasta_input|
        request = Typhoeus::Request.new(
          @url,
          method: :post,
          body: url_options(sub_division),
          accept_encoding: 'gzip',
          headers: { 'User-Agent' => @user_agent }
        )
        request.on_complete do |resp|
          if resp.success?
            # if JSON parsing goes wrong
            sub_result = JSON[resp.response_body] rescue []
            sub_result = [sub_result] unless sub_result.is_a? Array

            sub_result.map! { |r| r.select! { |k, _v| filter_list.any? { |f| f.match k } } } unless filter_list.empty?

            if options[:xml]
              result << sub_result
            end

            # wait till it's our turn to write
            batch_order.wait(i) do
              unless sub_result.empty?
                unless printed_header
                  write_to_output formatter.header(sub_result, fasta_input)
                  printed_header = true
                end
                write_to_output formatter.format(sub_result, fasta_input)
              end
            end

          elsif resp.timed_out?

            batch_order.wait(i) do
              $stderr.puts 'request timed out, continuing anyway, but results might be incomplete'
              save_error('request timed out, continuing anyway, but results might be incomplete')
            end

          elsif resp.code == 0

            batch_order.wait(i) do
              $stderr.puts 'could not get an http response, continuing anyway, but results might be incomplete'
              save_error(resp.return_message)
            end

          else

            batch_order.wait(i) do
              $stderr.puts "received a non-successful http response #{resp.code}, continuing anyway, but results might be incomplete"
              save_error("Got #{resp.code}: #{resp.response_body}\nRequest headers: #{resp.request.options}\nRequest body:\n#{resp.request.encoded_body}\n\n")
            end

          end
        end

        hydra.queue request

        num_req += 1
        if num_req % 200 == 0
          hydra.run
        end
      end

      hydra.run

      begin
        download_xml(result)
      rescue
        STDERR.puts 'Something went wrong while downloading xml information! please check the output'
      end
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

    def download_xml(result)
      return unless options[:xml]
      File.open(options[:xml] + '.xml', 'wb') do |f|
        f.write Typhoeus.get("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=#{result.first.map { |h| h['taxon_id'] }.join(',')}&retmode=xml").response_body
      end
    end

    def peptide_iterator(peptides, &block)
      first = peptides.next rescue return
      if first.start_with? '>'
        # FASTA MODE ENGAGED
        fasta_header = first.chomp
        peptides.each_slice(batch_size).with_index do |sub, i|
          fasta_input = []
          # Use a set so we don't ask data twice
          newsub = Set.new

          # Iterate to find fasta headers
          sub.each do |s|
            s.chomp!
            if s.start_with? '>'
              # Save the FASTA header when found
              fasta_header = s
            else
              # Add the input pair to our input list
              fasta_input << [fasta_header, s]
              newsub << s
            end
          end

          block.call(newsub.to_a, i, fasta_input)
        end
      else
        # shame we have to be this explicit, but it appears to be the only way
        Enumerator.new do |y|
          y << first
          loop do
            y << peptides.next
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
