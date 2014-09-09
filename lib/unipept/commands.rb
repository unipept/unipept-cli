['pept2lca','pept2taxa','pept2prot','taxa2lca','taxonomy'].each do |cmd|
  require_relative File.join('commands',cmd)
end
module Unipept
  module Commands
  end
end
