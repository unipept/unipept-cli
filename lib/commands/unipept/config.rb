module Unipept
  class Commands::Config < Cri::CommandRunner
    def run
      config = Unipept::Configuration.new
      key = arguments[0]
      value = arguments[1]
      if arguments.size == 2
        config[key] = value
        config.save
        puts key +  ' was set to ' + value
      elsif arguments.size == 1
        puts config[key]
      else
        puts command.help
      end
    end
  end
end
