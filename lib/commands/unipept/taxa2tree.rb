require_relative 'api_runner'
module Unipept::Commands
  class Taxa2Tree < ApiRunner
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
  end
end

