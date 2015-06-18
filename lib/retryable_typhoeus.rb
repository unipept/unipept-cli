# Retryable Typheous
# Inspiration: https://gist.github.com/kunalmodi/2939288
# Patches the request and hydra to allow requests to get resend when they fail

module RetryableTyphoeus
  require 'typhoeus'

  include Typhoeus

  DEFAULT_RETRIES = 10

  class Request < Typhoeus::Request
    attr_accessor :retries

    def initialize(base_url, options = {})
      @retries = (options.delete(:retries) || DEFAULT_RETRIES)

      super
    end

    def finish(response, bypass_memoization = nil)
      if response.success? || @retries <= 0
        super
      else
        @retries -= 1
        @hydra.queue_front self
      end
    end
  end
end
