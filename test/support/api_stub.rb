require 'json'

# This class stubs the Unipept API that's being used during the tests.
class ApiStub
  def setup_stubs
    @base_url = 'http://unipept.ugent.be/'

    setup_pept2ec
    setup_pept2go
  end

  def setup_pept2ec
    ecs = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'resources/pept2ec.json')))
    Typhoeus.stub('http://api.unipept.ugent.be/api/v1/pept2ec.json').and_return do |req|
      peptides = req.options[:body][:input]
      equateIl = req.options[:body][:equate_il]
      extra = req.options[:body][:extra]

      filtered = ecs.filter { |ec| peptides.include? ec['peptide'] }

      # Remove name field from output
      unless extra
        filtered.each { |ec| ec["ec"].delete("name") }
      end

      Typhoeus::Response.new(code: 200, body: JSON.dump(filtered))
    end
  end

  def setup_pept2go
    gos = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'resources/pept2go.json')))
    Typhoeus.stub('http://api.unipept.ugent.be/api/v1/pept2go.json').and_return do |req|
      peptides = req.options[:body][:input]

      filtered = gos.filter { |go| peptides.include? go['peptide'] }

      Typhoeus::Response.new(code: 200, body: JSON.dump(filtered))
    end
  end
end
