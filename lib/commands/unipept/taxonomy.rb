require_relative 'api_runner'
module Unipept::Commands
  class Taxonomy < ApiRunner
    def batch_size
      100
    end
  end
end
