['pept2lca'].each do |cmd|
  require_relative File.join('commands',cmd)
end
module Unipept
  module Commands
  end
end
