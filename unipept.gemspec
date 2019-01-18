# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: unipept 1.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "unipept".freeze
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Toon Willems".freeze, "Bart Mesuere".freeze, "Tom Naessens".freeze]
  s.date = "2019-01-18"
  s.description = "    Command line interface to the Unipept (http://unipept.ugent.be) web services\n    (pept2lca, taxa2lca, pept2taxa, pept2prot and taxonomy) and some utility\n    commands for handling proteins using the command line.\n".freeze
  s.email = "unipept@ugent.be".freeze
  s.executables = ["unipept".freeze, "prot2pept".freeze, "peptfilter".freeze, "uniprot".freeze]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rubocop.yml",
    ".ruby-version",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/peptfilter",
    "bin/prot2pept",
    "bin/unipept",
    "bin/uniprot",
    "lib/batch_iterator.rb",
    "lib/batch_order.rb",
    "lib/commands.rb",
    "lib/commands/peptfilter.rb",
    "lib/commands/prot2pept.rb",
    "lib/commands/unipept.rb",
    "lib/commands/unipept/api_runner.rb",
    "lib/commands/unipept/config.rb",
    "lib/commands/unipept/pept2lca.rb",
    "lib/commands/unipept/pept2prot.rb",
    "lib/commands/unipept/pept2taxa.rb",
    "lib/commands/unipept/taxa2lca.rb",
    "lib/commands/unipept/taxonomy.rb",
    "lib/commands/uniprot.rb",
    "lib/configuration.rb",
    "lib/formatters.rb",
    "lib/output_writer.rb",
    "lib/retryable_typhoeus.rb",
    "lib/server_message.rb",
    "lib/version.rb",
    "test/commands/test_peptfilter.rb",
    "test/commands/test_prot2pept.rb",
    "test/commands/test_unipept.rb",
    "test/commands/test_uniprot.rb",
    "test/commands/unipept/test_api_runner.rb",
    "test/commands/unipept/test_config.rb",
    "test/commands/unipept/test_pept2lca.rb",
    "test/commands/unipept/test_pept2prot.rb",
    "test/commands/unipept/test_pept2taxa.rb",
    "test/commands/unipept/test_taxa2lca.rb",
    "test/commands/unipept/test_taxonomy.rb",
    "test/helper.rb",
    "test/test_batch_iterator.rb",
    "test/test_batch_order.rb",
    "test/test_configuration.rb",
    "test/test_formatters.rb",
    "test/test_output_writer.rb",
    "test/test_retryable_typhoeus.rb",
    "test/test_server_message.rb",
    "unipept.gemspec"
  ]
  s.homepage = "http://unipept.ugent.be".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.1".freeze
  s.summary = "Command line interface to Unipept web services.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cri>.freeze, ["= 2.11"])
      s.add_runtime_dependency(%q<typhoeus>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.4"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.7"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.32"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0"])
    else
      s.add_dependency(%q<cri>.freeze, ["= 2.11"])
      s.add_dependency(%q<typhoeus>.freeze, ["~> 1.1"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.7"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.32"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0"])
    end
  else
    s.add_dependency(%q<cri>.freeze, ["= 2.11"])
    s.add_dependency(%q<typhoeus>.freeze, ["~> 1.1"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.7"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.32"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0"])
  end
end

