require_relative 'api_runner'
module Unipept::Commands
  class Taxa2Tree < ApiRunner
    def initialize(args, opts, cmd)
      super

      # JSON is the default format for this command
      args[:format] = 'json' unless args[:format]

      unless %w[url html json].include? args[:format]
        warn "Format #{args[:format]} is not supported by taxa2tree. Use html, url or json (default)."
        exit 1
      end

      if options[:format] == 'html'
        # Overwrite the URL for this command, since it's possible that it uses HTML generated by the server.
        @url = "#{@host}/api/v1/#{cmd.name}.html"
      elsif args[:format] == 'url'
        @link = true
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

    protected

    def filter_result(json_response)
      # We do not filter here, since select is not supported by the taxa2tree-command
      json_response
    end

    def construct_request_body(input)
      if input.empty? && input[0].include?(',')
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
