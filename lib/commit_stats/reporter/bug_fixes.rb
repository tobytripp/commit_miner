require "fastercsv"
require "parallel"

module CommitStats::Reports
  class BugFixes
    def initialize
      @git = ::Git.open CommitStats::Config.git_repo
      @bug_contributors = []
    end
    
    def gather_bugged_shas
      commits = CommitStats::Commit.find( :all,
        :order      => "date ASC",
        :conditions => ["feature LIKE ?", "%MMH-%"]
      )
      
      data = []
      commits.each_slice( commits.size / Parallel.processor_count + 1 ) { |i| 
        data << i
      }
      
      @bug_contributors = Parallel.in_processes do |i|
        get_bugged_shas_for_commits( data[i] )
      end
      
      CommitStats::LOG.warn "Found #{@bug_contributors.size} buggy commits…"
      @bug_contributors
    end
    
    def get_bugged_shas_for_commits( commits )
      buggy_shas = []
      commits.each do |commit|
        obj = @git.object commit.sha
        file = commit.changeset.first
        
        obj.diff_parent.patch.each_line do |patch_line|
          case patch_line.strip
          when /^--- a\/(.*)$/
            file = $1
            CommitStats::LOG.info file
          when /^-\s+(.*)$/
            match = $1.gsub( /([$"])/, '\\\\\1' )
            CommitStats::LOG.debug "(#{Process.pid}) BUG: " + match

            cmd = "git log --pretty=oneline -S\"#{match}\" #{file}"
            begin
              offenders = send( :`, cmd ).split("\n")
              CommitStats::LOG.error "Error running: #{cmd}" unless $? == 0
            rescue
              CommitStats::LOG.error "Error running: #{cmd}"
            end
            
            unless offenders.nil? || offenders.empty?
              sha = offenders.first.split.first
              buggy_shas << sha
            else
              CommitStats::LOG.warn "No Matching commit in #{file}"
            end
          end
        end
      end
      
      buggy_shas.uniq
    end
    
    def mark_bugged_commits( shas )
      shas.each do |sha|
        Commit.find_by_sha( sha ).bug!
      end
    end
    
    def to_csv
      mark_bugged_commits gather_bugged_shas
      
      FasterCSV.generate do |csv|
        csv << %w[SHA]
        
        @bug_contributors.each do |commit|
          csv << [
            commit
          ].map { |field| field.to_s }
        end
      end
    end
  end
end
