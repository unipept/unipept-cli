require 'json'

# This class stubs the Unipept API that's being used during the tests.
class ApiStub
  def setup_stubs
    @base_url = 'http://unipept.ugent.be/'

    %w[pept2ec pept2go pept2interpro pept2funct pept2lca pept2prot pept2taxa peptinfo].each do |endpoint|
      setup_endpoint endpoint
    end
  end

  def setup_endpoint(name)
    items = JSON.parse(File.read(File.join(File.dirname(__FILE__), "resources/#{name}.json")))
    Typhoeus.stub("http://api.unipept.ugent.be/api/v1/#{name}.json").and_return do |req|
      peptides = req.options[:body][:input]

      filtered = items.filter { |item| peptides.include? item['peptide'] }

      Typhoeus::Response.new(code: 200, body: JSON.dump(filtered))
    end
  end
end
