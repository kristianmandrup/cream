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
  gem.name = "cream"
  gem.summary = %Q{Integrates Devise, CanCan with permits and Roles generic for multiple ORMs}
  gem.description = %Q{An integrated Authentication, Authorization and Roles solution for your Rails 3 app with support for multiple ORMs}
  gem.email = "kmandrup@gmail.com"
  gem.homepage = "http://github.com/kristianmandrup/cream"
  gem.authors = ["Kristian Mandrup"]

# gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  # add more gem options here    
end    

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cantango #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


