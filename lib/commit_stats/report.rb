require "commit_stats/miner/git"  unless defined? CommitStats::Miner::Git
require "commit_stats/miner/jira" unless defined? CommitStats::Miner::Jira
require "commit_stats/miner/cruise_control" unless defined? CommitStats::Miner::CruiseControl

%w[commit bug_count broken_build].each do |model|
  require "commit_stats/models/#{model}"
end

%w[commits tests_and_cowboys bug_fixes].each do |report|
  require "commit_stats/reporter/#{report}"
end

module CommitStats
  LOG = Logger.new( STDOUT )
  
  def log() LOG; end
  
  class Report
    attr_reader   :stats
    attr_accessor :since_date, :output_path, :git_log, :report_only

    REPORT_PATH = File.expand_path( File.dirname(__FILE__) + "/reporter" )

    def self.available_reports
      CommitStats::LOG.debug "Finding reports in path: #{REPORT_PATH}"
      
      Dir["#{REPORT_PATH}/**/*.rb"].map { |path|
        File.basename( path, ".rb" )
      }
    end

    def initialize( options={} )
      @stats = options[:statistics] || [
        Miner::Git.new(  Config.git_repo, options[:since_date] ),
        Miner::Jira.new( Config.jira_url),
        Miner::CruiseControl.new( Config.cruise_url, Config.cruise_project )
      ]

      LOG.level = options.delete(:log_level) || Logger::WARN

      options.keys.each do |option|
        send( "#{option}=", options[option] ) if options[option]
      end
    end

    def report_only?() report_only; end

    def generate
      @stats.each { |stat| stat.gather_statistics } unless report_only?
    end
    
    def run( report_name )
      report_class = ('::CommitStats::Reports::' + report_name.camelize).constantize
      report_class.new
    end

    def commits
      Reports::Commits.new
    end

    def tests_and_cowboys
      Reports::TestsAndCowboys.new
    end
  end
end
