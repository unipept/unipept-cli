require_relative '../lib/batch_iterator'

module Unipept
  class BatchIteratorTestCase < Unipept::TestCase
    def test_batch_size
      iterator = BatchIterator.new(50)
      assert_equal(50, iterator.batch_size)
    end

    def test_fasta
      iterator = BatchIterator.new(50)
      assert(iterator.fasta?('> test'))
      assert(!(iterator.fasta? '< test'))
      assert(!(iterator.fasta? 'test'))
    end

    def test_normal_iterator
      iterator = BatchIterator.new(2)
      data = %w(a b c d e)
      out, _err = capture_io_while do
        iterator.iterate(data.each) do |batch, batch_id, fasta_mapper|
          assert_nil(fasta_mapper)
          puts batch_id
          puts batch.to_s
        end
      end
      assert_equal(['0', '["a", "b"]', '1', '["c", "d"]', '2', '["e"]', ''].join("\n"), out)
    end

    def test_fasta_iterator_single_header
      iterator = BatchIterator.new(2)
      data = %w(>h1 a b c d e)
      mappings = []
      out, _err = capture_io_while do
        iterator.iterate(data.each) do |batch, batch_id, fasta_mapper|
          assert(!fasta_mapper.nil?)
          mappings << fasta_mapper
          puts batch_id
          puts batch.to_s
        end
      end
      assert_equal(['0', '["a"]', '1', '["b", "c"]', '2', '["d", "e"]', ''].join("\n"), out)
      mappings.flatten!(1)
      data.shift
      data.each { |element| assert(mappings.include?(['>h1', element])) }
    end

    def test_fasta_iterator_double_header_single_batch
      iterator = BatchIterator.new(3)
      data = %w(>h1 a >h2 b c d e)
      mappings = []
      out, _err = capture_io_while do
        iterator.iterate(data.each) do |batch, batch_id, fasta_mapper|
          assert(!fasta_mapper.nil?)
          mappings << fasta_mapper
          puts batch_id
          puts batch.to_s
        end
      end
      assert_equal(['0', '["a"]', '1', '["b", "c", "d"]', '2', '["e"]', ''].join("\n"), out)
      mappings.flatten!(1)
      assert(mappings.include?(['>h1', 'a']))
      assert(mappings.include?(['>h2', 'b']))
      assert(mappings.include?(['>h2', 'c']))
      assert(mappings.include?(['>h2', 'd']))
      assert(mappings.include?(['>h2', 'e']))
    end

    def test_fasta_iterator_multiple_values
      iterator = BatchIterator.new(4)
      data = %w(>h1 a >h2 a a)
      mappings = []
      out, _err = capture_io_while do
        iterator.iterate(data.each) do |batch, batch_id, fasta_mapper|
          assert(!fasta_mapper.nil?)
          mappings << fasta_mapper
          puts batch_id
          puts batch.to_s
        end
      end
      assert_equal(['0', '["a"]', '1', '["a"]', ''].join("\n"), out)
      assert(mappings[0].include?(['>h1', 'a']))
      assert(mappings[0].include?(['>h2', 'a']))
      assert(mappings[1].include?(['>h2', 'a']))
    end
  end
end
