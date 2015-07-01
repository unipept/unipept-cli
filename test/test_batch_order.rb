require_relative '../lib/batch_order'

module Unipept
  class BatchOrderTestCase < Unipept::TestCase
    def test_single_batch
      order = BatchOrder.new
      out, _err = capture_io_while do
        run_batch(order, [0])
      end
      assert_equal(['0', ''].join("\n"), out)
    end

    def test_double_batch
      order = BatchOrder.new
      out, _err = capture_io_while do
        run_batch(order, [0, 1])
      end
      assert_equal(['0', '1', ''].join("\n"), out)
    end

    def test_missing_batch
      order = BatchOrder.new
      out, _err = capture_io_while do
        run_batch(order, [1, 2])
      end
      assert_equal('', out)
    end

    def test_out_order_batch
      order = BatchOrder.new
      out, _err = capture_io_while do
        run_batch(order, [1, 0])
      end
      assert_equal(['0', '1', ''].join("\n"), out)
    end

    def test_gap_batch
      order = BatchOrder.new
      out, _err = capture_io_while do
        run_batch(order, [1, 4, 0])
      end
      assert_equal(['0', '1', ''].join("\n"), out)
      out, _err = capture_io_while do
        run_batch(order, [2, 3, 5])
      end
      assert_equal(['2', '3', '4', '5', ''].join("\n"), out)
    end

    def run_batch(order, list)
      list.each do |i|
        order.wait(i) do
          puts i
        end
      end
    end
  end
end
