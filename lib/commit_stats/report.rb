require "commit_stats/miner/git"
require "commit_stats/miner/jira"
require "commit_stats/miner/cruise_control"

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
    attr_reader   :miner
    attr_accessor :since_date, :report_only, :multiprocess
    alias_method :report_only?,  :report_only
    alias_method :multiprocess?, :multiprocess

    REPORT_PATH = File.expand_path( File.dirname(__FILE__) + "/reporter" )

    def self.available_reports
      CommitStats::LOG.debug "Finding reports in path: #{REPORT_PATH}"
      
      Dir["#{REPORT_PATH}/**/*.rb"].map { |path|
        File.basename( path, ".rb" )
      }
    end

    def initialize( options={} )
      miners = options.delete(:miners) || [ "git", "jira", "cruise_control" ]
      @miners = create_miners( miners, options )
      self.multiprocess = true

      CommitStats::LOG.level = options.delete(:log_level) || Logger::WARN

      options.keys.each do |option|
        self.send( "#{option}=".to_sym, options[option] ) unless options[option].nil?
      end
    end

    def generate
      unless report_only?
        CommitStats::LOG.info "running miners…"
        @miners.each do |miner|
          mine = lambda {
            miner.gather_statistics
            CommitStats::LOG.info "#{miner.class.name} Finished"
          }
          
          if multiprocess?
            fork &mine
          else
            mine.call
          end
        end
        
        CommitStats::LOG.info "waiting for miners to complete…"
        Process.waitall
        CommitStats::LOG.info "miners complete."
      end
    end
    
    def run( report_name )
      CommitStats::LOG.info "running report #{report_name}…"
      report_class = ('::CommitStats::Reports::' + report_name.camelize).constantize
      report_class.new
    end
    
    protected
    
    def create_miners( miner_list, options )
      miner_list.map { |miner_name| 
        miner_class = ('::CommitStats::Miner::' + miner_name.camelize).constantize
        miner_class.new options
      }
    end
  end
end
