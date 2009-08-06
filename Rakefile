require 'rubygems'

require 'rake'
require "rake/gempackagetask"
require 'spec/rake/spectask'
require "activerecord"

task :default => :spec

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new( :spec ) do |t|
  t.spec_opts = ['--options', "\"./spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Setup application environment"
task :environment do
  $LOAD_PATH << File.expand_path( File.dirname(__FILE__) + "/lib" )
  require "commit_stats"
end

namespace :db do
  desc "Migrate the datbasse"
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new STDOUT
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate(
      File.expand_path( File.dirname(__FILE__) + "/db/migrate" ),
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    )
    Rake::Task["db:schema:dump"].invoke
  end
  
  desc "Dump the current db schema"
  task "schema:dump" => :environment do
    require 'active_record/schema_dumper'
    File.open(
      ENV['SCHEMA'] || File.expand_path( File.dirname(__FILE__) + "/db/schema.rb"),
      "w"
    ) do |file|
      ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, file
    end
  end
end

spec = Gem::Specification.new do |s|
  s.name    = "commit_stats"
  s.version = "0.0.1"
  s.author  = "Toby Tripp"
  
  s.platform = Gem::Platform::RUBY
  s.summary  = "Mine Git repositories, cruise, and jira for data and report."
  s.default_executable = 'bin/commitstats'
  
  s.files = FileList.new.add( %w[
    lib/**/*.rb
    bin/*
    Rakefile
    README.rdoc
    script/*
    db/migrate/*
    config/*
  ] ).to_a 
  
  s.test_files = FileList["spec/**/*_spec.rb"]
  
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.add_dependency "rake",         ">= 0.8.7"
  s.add_dependency "git",          ">= 1.0.5"
  s.add_dependency "mechanize",    ">= 0.9.3"
  s.add_dependency "activerecord", ">= 2.3.2"
  
  s.add_development_dependency 'rspec', ">= 1.2.8"
  s.add_development_dependency 'rr'
end

Rake::GemPackageTask.new( spec ) do |pkg|
  pkg.need_tar = true
end