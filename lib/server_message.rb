require 'typhoeus'

require_relative 'configuration'

module Unipept
  class ServerMessage
    attr_reader :message_url, :configuration

    def initialize(host)
      @message_url = "#{host}/api/v1/messages.json"
      @configuration = Unipept::Configuration.new
    end

    # Checks if the server has a message and prints it if not empty.
    # We will only check this once a day and won't print anything if the quiet
    # option is set or if we output to a file.
    def print
      return unless $stdout.tty?
      return if recently_fetched?

      resp = fetch_server_message
      update_fetched
      puts resp unless resp.empty?
    end

    # Fetches a message from the server and returns it
    def fetch_server_message
      Typhoeus.get(@message_url, params: { version: Unipept::VERSION }).body.chomp
    end

    # Returns true if the last check for a server message was less than a day
    # ago.
    def recently_fetched?
      last_fetched = @configuration['last_fetch_date']
      !last_fetched.nil? && (last_fetched + (60 * 60 * 24)) > Time.now
    end

    # Updates the last checked timestamp
    def update_fetched
      @configuration['last_fetch_date'] = Time.now
      @configuration.save
    end
  end
end
