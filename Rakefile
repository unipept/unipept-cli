# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "unipept"
  gem.executables = ['unipept', 'prot2pept', 'peptfilter', 'uniprot']
  gem.homepage = "http://github.ugent.be/bmesuere/unipept/"
  gem.license = "MIT"
  gem.summary = %Q{CLI interface to unipept}
  gem.description = %Q{CLI interface to unipept}
  gem.email = "willemstoon@gmail.com"
  gem.authors = ["Toon Willems"]
  # dependencies defined in Gemfile
  gem.add_dependency 'typhoeus', '~> 0.6'
  gem.add_dependency 'cri', '~> 2.6'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "unipept #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
