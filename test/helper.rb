require 'rubygems'
require 'bundler'

require_relative 'support/api_stub'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'minitest'
require 'minitest/autorun'

module Unipept
  class TestCase < Minitest::Test
    def setup
      # Enter tmp
      @tmp_dir = Dir.mktmpdir('unipept-test')
      @orig_wd = FileUtils.pwd
      FileUtils.cd(@tmp_dir)

      @orig_io = capture_io

      setup_api_stubs
    end

    def teardown
      uncapture_io(*@orig_io)

      # Exit tmp
      FileUtils.cd(@orig_wd)
      FileUtils.rm_rf(@tmp_dir)
    end

    def capture_io_with_input(input)
      capture_io_while do
        input = input.join("\n") if input.is_a? Array
        $stdin.write(input)
        $stdin.rewind
        yield
      end
    end

    def capture_io_while
      orig_io = capture_io
      yield
      [$stdout.string, $stderr.string]
    ensure
      uncapture_io(*orig_io)
    end

    def lines(string)
      string.scan(/^.*\n/).map(&:chomp)
    end

    private

    def capture_io
      orig_stdout = $stdout
      orig_stderr = $stderr
      orig_stdin = $stdin

      $stdout = StringIO.new
      $stderr = StringIO.new
      $stdin = StringIO.new

      [orig_stdout, orig_stderr, orig_stdin]
    end

    def uncapture_io(orig_stdout, orig_stderr, orig_stdin)
      $stdout = orig_stdout
      $stderr = orig_stderr
      $stdin = orig_stdin
    end

    # Setup the interceptors for API requests, that will reply with a predefined (static) set of data
    def setup_api_stubs
      api_stub = ApiStub.new
      api_stub.setup_stubs
    end
  end
end

# Unexpected system exit is unexpected
::MiniTest::Unit::TestCase::PASSTHROUGH_EXCEPTIONS.delete(SystemExit)
