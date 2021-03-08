require 'yaml'

module Unipept
  class Configuration
    attr_reader :config, :file_name

    # Creates a new config object, based on a given YAML file. If no filename
    # given, '.unipeptrc' in the home dir of the user will be used.
    #
    # If the file doesn't exist, an empty config will be loaded.
    #
    # @param [String] file An optional file name of the YAML file to create the
    # config from
    def initialize(file = nil)
      @file_name = file || File.join(Dir.home, '.unipeptrc')
      @config = if !File.exist? file_name
                  {}
                else
                  YAML.load_file file_name
                end
    end

    # Saves the config to disk. If the file doesn't exist yet, a new one will be
    # created
    def save
      File.open(file_name, 'w') { |f| f.write config.to_yaml }
    end

    # Deletes a key
    def delete(key)
      config.delete(key)
    end

    # forwards [] to the internal config hash
    def [](*args)
      config.[](*args)
    end

    # forwards =[] to the internal config hash
    def []=(*args)
      config.[]=(*args)
    end
  end
end
