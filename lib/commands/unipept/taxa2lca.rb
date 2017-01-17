require_relative 'api_runner'
module Unipept::Commands
  class Taxa2lca < ApiRunner
    def batch_iterator
      SimpleBatchIterator.new
    end

    def default_batch_size
      raise 'NOT NEEDED FOR TAXA2LCA'
    end
  end

  class SimpleBatchIterator
    def iterate(input)
      yield(input.to_a, 0)
    end
  end
end
