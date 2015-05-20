require_relative 'api_runner'
module Unipept::Commands
  class Taxa2lca < ApiRunner
    def peptide_iterator(peptides, &block)
      block.call(peptides.to_a, 0)
    end

    def batch_size
      fail 'NOT NEEDED FOR TAXA2LCA'
    end
  end
end
