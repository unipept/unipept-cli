require_relative 'api_runner'
module Unipept::Commands
  class Taxa2Tree < ApiRunner
    def initialize(args, opts, cmd)
      super

      # JSON is the default format for this command
      unless args[:format]
        args[:format] = "json"
      end

      unless %w(url html json).include? args[:format]
        warn "Format #{args[:format]} is not supported by taxa2tree. Use html, url or json (default)."
        exit 1
      end

      # Overwrite the URL for this command, since it's possible that it uses HTML generated by the server.
      if options[:format] == "html"
        @url = "#{@host}/api/v1/#{cmd.name}.html"
      elsif args[:format] == "url"
        @link = true
        options[:format] = "json"
      end
    end

    def handle_success_response(response, batch_id, fasta_mapper)
      result = response.response_body
      # We cannot filter and select fields if the format is HTML
      unless options[:format] == "html"
        result = filter_result(result)
      end

      lambda do
        unless result.empty?
          output_writer.write_line formatter.header(result, fasta_mapper) if batch_id.zero? && !options[:"no-header"]
          output_writer.write_line formatter.format(result, fasta_mapper, batch_id.zero?)
        end
      end
    end

    def required_fields
      ['taxon_id']
    end

    def default_batch_size
      if options[:all]
        100
      else
        1000
      end
    end

    def construct_request_body(input)
      if input.length > 0 and input[0].include? ','
        data = input.map do |item|
          splitted = item.rstrip.split ','
          splitted[1] = splitted[1].to_i
          splitted
        end

        {
            counts: Hash[data],
            link: @link
        }
      else
        {
            input: input,
            link: @link
        }
      end
    end
  end
end

