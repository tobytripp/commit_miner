require 'rubygems'

require 'rake'
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
    ActiveRecord::Migrator.migrate "db/migrate", ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    Rake::Task["db:schema:dump"].invoke
  end
  
  desc "Dump the current db schema"
  task "schema:dump" => :environment do
    require 'active_record/schema_dumper'
    File.open( ENV['SCHEMA'] || "db/schema.rb", "w" ) do |file|
      ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, file
    end
  end
end
