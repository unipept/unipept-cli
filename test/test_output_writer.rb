require_relative '../lib/output_writer'

module Unipept
  class OutputWriterTestCase < Unipept::TestCase
    def test_init
      assert_equal($stdout, OutputWriter.new(nil).output)
      assert_equal(File, OutputWriter.new('output.txt').output.class)
    end

    def test_stdout_write_to_output
      out, _err = capture_io_while do
        writer = OutputWriter.new(nil)
        writer.write_line('hello world')
        writer.output.flush
      end
      assert_equal('hello world', out.chomp)
    end

    def test_file_write_to_output
      out, _err = capture_io_while do
        writer = OutputWriter.new('output_file')
        writer.write_line('hello world')
        writer.output.flush
      end
      assert_equal('', out)
      assert_equal('hello world', IO.foreach('output_file').next.chomp)
    end
  end
end
