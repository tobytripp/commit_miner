module CommitStats
  class ConfigError < StandardError
    def initialize( message ) super; end
  end
  
  class Configurator
    attr_accessor(
      :cruise_url,
      :cruise_project,
      :git_repo,
      :jira_url
    )
    
    def self.load( config_data="" )
      config = new config_data
    end
    
    def initialize( config_data="" )
      eval config_data, binding, __FILE__, __LINE__
    end
    
    def method_missing( method_name, *args )
      if method_name.to_s =~ /([^=]+)=$/
        self.class.class_eval "attr_accessor :#{$1}"
        self.send method_name, args
      else
        raise ConfigError, "'#{method_name}' is not defined"
      end
    end
    
    def configure( &block )
      yield self
    end
    alias_method :configurate, :configure
  end

  CONFIG_PATH = [
    File.expand_path( "." ),
    File.expand_path( "./config" ),
    File.expand_path( "~/" ),
    File.expand_path( "~/.commit_stats" ),
    APP_ROOT,
    "#{APP_ROOT}/config"
  ].detect do |path|
    File.file? File.join( path, "commit_stats.config.rb" )
  end

  unless ENV["APP_ENV"] == "test"
    puts "Loading configuration at #{CONFIG_PATH}/commit_stats.config.rb"
    Config =
      Configurator.load File.read( File.join( CONFIG_PATH, "commit_stats.config.rb" ) )
  else
    Config = Configurator.new
  end
end
