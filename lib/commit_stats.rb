APP_ROOT = File.expand_path File.join( File.dirname(__FILE__), '..' )

require "database"
require "commit_stats/configurator"
require "commit_stats/report"

DB_PATH = File.expand_path( "~/.commit_stats/db/commit_data.sqlite3" )
unless File.exists? DB_PATH
  require "fileutils"
  FileUtils.mkdir_p File.dirname( DB_PATH )

  puts "Initializing database in #{DB_PATH}"
  
  load File.expand_path( "#{APP_ROOT}/Rakefile" )
  Rake::Task["db:migrate"].invoke
end
