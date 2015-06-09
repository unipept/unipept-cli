require_relative 'api_runner'

module Unipept::Commands
  class Pept2prot < ApiRunner
    def batch_size
      10
    end
  end
end
