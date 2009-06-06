begin
  require "activerecord"
rescue LoadError => e
  puts "Unsatisfied dependency: #{e}"
  puts "sudo gem install activerecord"
  exit 1
end

require 'erb'

env = ENV["DB_ENV"] || "development"

config_yaml = ERB.new( File.read( "#{APP_ROOT}/config/database.yml" ) ).result binding
db_config   = YAML.load( config_yaml )[env]

ActiveRecord::Base.establish_connection db_config
