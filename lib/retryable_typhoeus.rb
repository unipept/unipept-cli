# Retryable Typheous
# Inspiration: https://gist.github.com/kunalmodi/2939288
# Patches the request and hydra to allow requests to get resend when they fail

module RetryableTyphoeus
  require 'typhoeus'

  include Typhoeus

  DEFAULT_RETRIES = 10

  class Request < Typhoeus::Request
    def initialize(base_url, options = {})
      @retries = (options.delete(:retries) || DEFAULT_RETRIES)

      super
    end

    def retries=(retries)
      @retries = retries
    end

    def retries
      @retries ||= 0
    end
  end

end
