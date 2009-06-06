module CommitStats
  class ConfigError < StandardError
    def initialize( message ) super; end
  end
  
  class Configurator
    attr_accessor :cruise_url, :cruise_project, :git_repo, :jira_url
    
    def self.load( config_data="" )
      config = new config_data
    end
    
    def initialize( config_data="" )
      eval config_data, binding, __FILE__, __LINE__
    end
    
    def configure( &block )
      yield self
    end
    alias_method :configurate, :configure
  end

  CONFIG_PATH = [
    File.expand_path( "." ),
    File.expand_path( "~/" ),
    File.expand_path( "~/.commit_stats" ),
    APP_ROOT
  ].detect do |path|
    File.file? File.join( path, "commit_stats.config.rb" )
  end

  unless ENV["APP_ENV"] == "test"
    Config = Configurator.load File.read( File.join( CONFIG_PATH, "commit_stats.config.rb" ) )
  end
end
