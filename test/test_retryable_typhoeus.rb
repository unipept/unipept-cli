require_relative '../lib/retryable_typhoeus'

module Unipept
  class BatchIteratorTestCase < Unipept::TestCase
    def test_request_retry_default_parameter
      request = new_request
      assert_equal(10, request.retries)
      request.retries = 3
      assert_equal(3, request.retries)
    end

    def test_request_retry_parameter
      request = new_request(retries: 5)
      assert_equal(5, request.retries)
    end

    def new_request(extra_opts = {})
      ::RetryableTyphoeus::Request.new(
          'url',
          options.merge(extra_opts)
      )
    end

    def options
      {
        method: :post,
        body: 'body',
        accept_encoding: 'gzip',
        headers: { 'User-Agent' => 'user-agent' }
      }
    end
  end
end
