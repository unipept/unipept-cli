module Unipept
  class Commands::Config < Cri::CommandRunner
    def run
      abort command.help if arguments.empty? || arguments.size > 2

      key, value = *arguments

      if arguments.size == 2
        set_config(key, value)
        puts key + ' was set to ' + value
      else
        puts get_config(key)
      end
    end

    def config
      @config ||= Unipept::Configuration.new
    end

    def set_config(key, value)
      config[key] = value
      config.save
    end

    def get_config(key)
      config[key]
    end
  end
end
