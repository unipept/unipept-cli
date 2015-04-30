require_relative 'api_runner'

module Unipept::Commands
  class Pept2prot < ApiRunner
    def download_xml(result)
      if options[:xml]
        FileUtils.mkdir_p(options[:xml])
        result.first.each do |prot|
          File.open(options[:xml] + "/#{prot['uniprot_id']}.xml", "wb") do |f|
            f.write Typhoeus.get("http://www.uniprot.org/uniprot/#{prot['uniprot_id']}.xml").response_body
          end
        end
      end
    end

    def batch_size
      10
    end
  end
end
