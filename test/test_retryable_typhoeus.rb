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

    def test_succesful_requests_complete
      hydra = new_hydra

      response = new_response
      Typhoeus.stub('stubbed.com').and_return(response)

      request = new_request

      hydra.queue request
      hydra.run

      assert_equal(10, request.retries)
      assert_equal(true, response.success?)
    end

    def test_failing_requests_retry
      hydra = new_hydra

      response_fail = new_response(400)
      response_success = new_response(200)
      Typhoeus::Expectation.clear
      Typhoeus.stub('stubbed.com').and_return([response_fail, response_success])

      request = new_request

      hydra.queue request
      hydra.run

      assert_equal(9, request.retries)
    end

    def test_failing_requests_finally_completes_with_error
      hydra = new_hydra
      response = new_response(400)
      Typhoeus.stub('stubbed.com').and_return(response)

      request = new_request

      hydra.queue request
      hydra.run

      assert_equal(0, request.retries)
      assert_equal(false, response.success?)
    end

    def new_request(extra_opts = {})
      ::RetryableTyphoeus::Request.new(
          'stubbed.com',
          request_options.merge(extra_opts)
      )
    end

    def request_options
      {
        method: :post,
        body: 'body',
        accept_encoding: 'gzip',
        headers: { 'User-Agent' => 'user-agent' }
      }
    end

    def new_hydra
      Typhoeus::Hydra.new(max_concurrency: 10)
    end

    def new_response(code = 200)
      Typhoeus::Response.new(code: code, body: {}, return_code: :ok)
    end
  end
end
