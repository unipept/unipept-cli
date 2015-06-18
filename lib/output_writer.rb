module Unipept
  class OutputWriter
    attr_reader :output

    def initialize(file)
      @output = file ? File.open(file, 'a') : $stdout
    end

    def write_line(line)
      @output.write line
    end
  end
end
