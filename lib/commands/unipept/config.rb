module Unipept
  class Commands::Config < Cri::CommandRunner
    def run
      if arguments.size == 0 || arguments.size > 2
        abort command.help
      end

      key, value = *arguments

      if arguments.size == 2
        set_config(key, value)
        puts key +  ' was set to ' + value
      else
        puts get_config(key)
      end
    end

    def config
      @config = Unipept::Configuration.new unless @config
      @config
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
