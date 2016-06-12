require_relative 'api_runner'
module Unipept::Commands
  class Taxonomy < ApiRunner
    def required_fields
      ['taxon_id']
    end

    def default_batch_size
      100
    end
  end
end
