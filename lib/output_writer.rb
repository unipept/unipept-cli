module Unipept
  class OutputWriter
    def initialize(file)
      @file  = File.open(file, 'a') if file
      @stdout = file.nil?
    end

    def write_line(string)
      if @stdout
        puts string
      else
        @file.write string
      end
    end
  end
end
