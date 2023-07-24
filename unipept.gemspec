# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: unipept 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "unipept".freeze
  s.version = "3.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bart Mesuere".freeze, "Pieter Verschaffelt".freeze, "Toon Willems".freeze, "Tom Naessens".freeze]
  s.date = "2023-07-24"
  s.description = "    Command line interface to the Unipept (http://unipept.ugent.be) web services\n    (pept2lca, taxa2lca, pept2taxa, pept2prot and taxonomy) and some utility\n    commands for handling proteins using the command line.\n".freeze
  s.email = "unipept@ugent.be".freeze
  s.executables = ["unipept".freeze, "prot2pept".freeze, "peptfilter".freeze, "uniprot".freeze]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".devcontainer/devcontainer.json",
    ".document",
    ".github/dependabot.yml",
    ".github/workflows/ci.yml",
    ".rakeTasks",
    ".rubocop.yml",
    ".ruby-version",
    ".vscode/tasks.json",
    "CITATION.cff",
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
    "lib/commands/unipept/pept2ec.rb",
    "lib/commands/unipept/pept2funct.rb",
    "lib/commands/unipept/pept2go.rb",
    "lib/commands/unipept/pept2interpro.rb",
    "lib/commands/unipept/pept2lca.rb",
    "lib/commands/unipept/pept2prot.rb",
    "lib/commands/unipept/pept2taxa.rb",
    "lib/commands/unipept/peptinfo.rb",
    "lib/commands/unipept/protinfo.rb",
    "lib/commands/unipept/taxa2lca.rb",
    "lib/commands/unipept/taxa2tree.rb",
    "lib/commands/unipept/taxonomy.rb",
    "lib/commands/uniprot.rb",
    "lib/configuration.rb",
    "lib/formatters.rb",
    "lib/output_writer.rb",
    "lib/retryable_typhoeus.rb",
    "lib/server_message.rb",
    "lib/version.rb",
    "test.taxa",
    "test/commands/test_peptfilter.rb",
    "test/commands/test_prot2pept.rb",
    "test/commands/test_unipept.rb",
    "test/commands/test_uniprot.rb",
    "test/commands/unipept/test_api_runner.rb",
    "test/commands/unipept/test_config.rb",
    "test/commands/unipept/test_pept2ec.rb",
    "test/commands/unipept/test_pept2funct.rb",
    "test/commands/unipept/test_pept2go.rb",
    "test/commands/unipept/test_pept2interpro.rb",
    "test/commands/unipept/test_pept2lca.rb",
    "test/commands/unipept/test_pept2prot.rb",
    "test/commands/unipept/test_pept2taxa.rb",
    "test/commands/unipept/test_peptinfo.rb",
    "test/commands/unipept/test_protinfo.rb",
    "test/commands/unipept/test_taxa2lca.rb",
    "test/commands/unipept/test_taxa2tree.rb",
    "test/commands/unipept/test_taxonomy.rb",
    "test/helper.rb",
    "test/support/api_stub.rb",
    "test/support/resources/pept2ec.json",
    "test/support/resources/pept2funct.json",
    "test/support/resources/pept2go.json",
    "test/support/resources/pept2interpro.json",
    "test/support/resources/pept2lca.json",
    "test/support/resources/pept2prot.json",
    "test/support/resources/pept2taxa.json",
    "test/support/resources/peptinfo.json",
    "test/support/resources/taxa2tree.json",
    "test/support/resources/taxonomy.json",
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
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Command line interface to Unipept web services.".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<cri>.freeze, ["~> 2.15.10"])
  s.add_runtime_dependency(%q<typhoeus>.freeze, ["~> 1.4.0"])
  s.add_runtime_dependency(%q<psych>.freeze, ["~> 5.1.0"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.18"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.1"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.50"])
end

