module Unipept
  class BatchOrder
    attr_reader :order

    def initialize
      @order = {}
      @current = 0
    end

    # Executes block if it's its turn, queues the block in the other case.
    def wait(i, &block)
      @order[i] = block
      return unless i == @current
      while order[@current]
        order.delete(@current).call
        @current += 1
      end
    end
  end
end
