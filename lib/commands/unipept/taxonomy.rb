require_relative 'api_runner'
module Unipept::Commands
  class Taxonomy < ApiRunner
    def default_batch_size
      100
    end
  end
end
