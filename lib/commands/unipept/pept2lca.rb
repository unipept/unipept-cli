require_relative 'api_runner'
module Unipept::Commands
  class Pept2lca < ApiRunner
    def batch_size
      if options[:all]
        100
      else
        1000
      end
    end
  end
end