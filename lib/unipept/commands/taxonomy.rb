require_relative 'api_runner'
module Unipept::Commands
  class Taxonomy < ApiRunner
    def mapping
      {"taxonomy" => "taxonomy"}
    end
  end
end
