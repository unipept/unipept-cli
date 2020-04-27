require_relative 'api_runner'
module Unipept::Commands
  class Pept2taxa < ApiRunner
    def required_fields
      ['peptide']
    end

    def default_batch_size
      5
    end
  end
end
