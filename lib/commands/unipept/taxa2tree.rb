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

    def batch_size
      return arguments.length unless arguments.empty?
      return File.foreach(options[:input]).inject(0) { |c, _| c + 1 } if options[:input]

      @stdin_contents = $stdin.readlines
      @stdin_contents.length
    end

    def input_iterator
      return arguments.each unless arguments.empty?
      return IO.foreach(options[:input]) if options[:input]

      @stdin_contents.each
    end

    protected

    def filter_result(response)
      return response if response.start_with?('<!DOCTYPE')

      # We do not filter here, since select is not supported by the taxa2tree-command
      [JSON[response]] rescue []
    end

    def construct_request_body(input)
      data = nil

      if input[0].include?(',')
        data = input.map do |item|
          splitted = item.rstrip.split ','
          splitted[1] = splitted[1].to_i
          splitted
        end
        data = Hash[data]
      else
        data = Hash.new 0
        input.each do |i|
          data[i.rstrip] += 1
        end
      end

      {
        counts: data,
        link: @link
      }
    end
  end
end
