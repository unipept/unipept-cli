require_relative 'api_runner'
module Unipept::Commands
  class Pept2ec < ApiRunner
    def required_fields
      ['peptide']
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
