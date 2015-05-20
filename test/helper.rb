require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'minitest'
require 'minitest/autorun'

module Unipept
  class TestCase < Minitest::Test
    # add helper methods here
  end
end

# Unexpected system exit is unexpected
::MiniTest::Unit::TestCase::PASSTHROUGH_EXCEPTIONS.delete(SystemExit)
