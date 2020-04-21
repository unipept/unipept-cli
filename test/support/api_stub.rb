require 'json'

# This class stubs the Unipept API that's being used during the tests.
class ApiStub
  def setup_stubs
    @base_url = 'http://unipept.ugent.be/'

    %w[pept2ec pept2go pept2interpro pept2funct pept2lca pept2prot pept2taxa peptinfo].each do |endpoint|
      setup_endpoint endpoint
    end

    setup_taxa2lca
    setup_taxonomy
  end

  def setup_endpoint(name)
    items = JSON.parse(File.read(File.join(File.dirname(__FILE__), "resources/#{name}.json")))
    Typhoeus.stub("http://api.unipept.ugent.be/api/v1/#{name}.json").and_return do |req|
      peptides = req.options[:body][:input]

      filtered = items.select { |item| peptides.include? item['peptide'] }

      Typhoeus::Response.new(code: 200, body: JSON.dump(filtered))
    end
  end

  def setup_taxa2lca
    Typhoeus.stub('http://api.unipept.ugent.be/api/v1/taxa2lca.json').and_return(
      Typhoeus::Response.new(code: 200, body: '{
        "taxon_id": 1678,
        "taxon_name": "Bifidobacterium",
        "taxon_rank": "genus"
      }')
    )
  end

  def setup_taxonomy
    items = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'resources/taxonomy.json')))
    Typhoeus.stub('http://api.unipept.ugent.be/api/v1/taxonomy.json').and_return do |req|
      taxa = req.options[:body][:input].map(&:to_i)

      filtered = items.select { |item| taxa.include? item['taxon_id'] }

      Typhoeus::Response.new(code: 200, body: JSON.dump(filtered))
    end
  end


end
