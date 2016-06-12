require_relative 'api_runner'

module Unipept::Commands
  class Pept2prot < ApiRunner
    def required_fields
      ['peptide']
    end

    def default_batch_size
      if options[:all]
        5
      else
        10
      end
    end
  end
end
