require_relative 'api_runner'
module Unipept::Commands
  class Protinfo < ApiRunner
    def required_fields
      ['protein']
    end

    def default_batch_size
      1000
    end
  end
end
