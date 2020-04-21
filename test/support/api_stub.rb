require 'json'

# This class stubs the Unipept API that's being used during the tests.
class ApiStub
  def setup_stubs
    @base_url = 'http://unipept.ugent.be/'

    setup_endpoint "pept2ec"
    setup_endpoint "pept2go"
    setup_endpoint "pept2interpro"
    setup_endpoint "pept2funct"
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
