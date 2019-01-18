require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
    gem.name = 'unipept'
    gem.executables = %w[unipept prot2pept peptfilter uniprot]
    gem.homepage = 'http://unipept.ugent.be'
    gem.license = 'MIT'
    gem.summary = 'Command line interface to Unipept web services.'
    gem.description = <<-EOS
    Command line interface to the Unipept (http://unipept.ugent.be) web services
    (pept2lca, taxa2lca, pept2taxa, pept2prot and taxonomy) and some utility
    commands for handling proteins using the command line.
    EOS
    gem.email = 'unipept@ugent.be'
    gem.authors = ['Toon Willems', 'Bart Mesuere', 'Tom Naessens']
    gem.required_ruby_version = '>= 2.0.0'
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  # do nothing
end

task :test_unit do
  require './test/helper.rb'

  FileList['./test/**/test_*.rb', './test/**/*_spec.rb'].each do |fn|
    require fn
  end
end

RuboCop::RakeTask.new(:test_style)

task test: %i[test_unit test_style]

task default: :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "unipept #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
