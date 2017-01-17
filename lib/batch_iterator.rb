require 'set'

module Unipept
  class BatchIterator
    attr_reader :batch_size

    def initialize(batch_size)
      @batch_size = batch_size
    end

    # Splits the input lines into slices, based on the batch_size of the current
    # command. Executes the given block for each of the batches.
    #
    # Supports both normal input and input in the fasta format.
    #
    # @input [Iterator] lines An iterator containing the input lines
    #
    # @input [lambda] block The code to execute on the slices
    def iterate(lines, &block)
      first_line = lines.next rescue return
      if fasta? first_line
        fasta_iterator(first_line, lines, &block)
      else
        normal_iterator(first_line, lines, &block)
      end
    end

    # Checks if the geven line is a fasta header.
    #
    # @param [String] line The input line
    #
    # @return [Boolean] Whether te input is a fasta header
    def fasta?(line)
      line.start_with? '>'
    end

    private

    # Splits the input lines in fasta format into slices, based on the
    # batch_size of the current command. Executes the given block for each of
    # the batches.
    def fasta_iterator(first_line, next_lines)
      current_fasta_header = first_line.chomp
      next_lines.each_slice(batch_size).with_index do |slice, i|
        fasta_mapper = []
        input_set = Set.new

        slice.each do |line|
          line.chomp!
          if fasta? line
            current_fasta_header = line
          else
            fasta_mapper << [current_fasta_header, line]
            input_set << line
          end
        end

        yield(input_set.to_a, i, fasta_mapper)
      end
    end

    # Splits the input lines into slices, based on the batch_size of the current
    # command. Executes the given block for each of the batches.
    def normal_iterator(first_line, next_lines, &block)
      Enumerator.new do |y|
        y << first_line
        loop do
          y << next_lines.next
        end
      end.each_slice(batch_size).with_index(&block)
    end
  end
end
