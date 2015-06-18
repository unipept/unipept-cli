module Unipept
  class OutputWriter
    def initialize(file)
      @output = file ? File.open(file, 'a') : $stdout
    end

    def write_line(string)
      @output.write string
    end
  end
end
