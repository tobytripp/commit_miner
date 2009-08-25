require "fastercsv"
require "parallel"
require "ostruct"

module CommitStats::Reports
  class BugFixes
    BuggyCommit = Struct.new( :sha, :bug )
    
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
      raise "data partition failed" unless data.size == Parallel.processor_count
      
      @bug_contributors = Parallel.in_processes { |i|
        get_bugged_shas_for_commits( data[i] )
      }.flatten
      
      CommitStats::LOG.warn "Found #{@bug_contributors.size} buggy commits…"
      @bug_contributors
    end
    
    def get_bugged_shas_for_commits( commits )
      buggy_commits = []

      commits.each do |commit|
        obj = @git.object commit.sha
        file = commit.changeset.first
        
        obj.diff_parent.patch.each_line do |patch_line|
          case patch_line.strip
          when /^--- a\/(.*)$/
            file = $1
            CommitStats::LOG.info file

          when /^-\s+(.*)$/
            buggy_commits << last_change_commit_for( commit.feature, file, $1 )
          end
        end
      end
      
      buggy_commits.compact.uniq
    end
    
    def last_change_commit_for( bug, file, change_string )
      match = change_string.gsub( /([$"])/, '\\\\\1' )
      CommitStats::LOG.debug "(#{Process.pid}) BUG: " + match

      cmd = "git log --pretty=oneline -S\"#{match}\" #{file}"
      begin
        offenders = send( :`, cmd ).split("\n")
        CommitStats::LOG.error "Error running: #{cmd}" unless $? == 0
      rescue
        CommitStats::LOG.error "Error running: #{cmd}"
      end
      
      unless offenders.nil? || offenders.empty?
        BuggyCommit.new offenders.first.split.first, bug
      else
        CommitStats::LOG.warn "No Matching commit in #{file}"
        nil
      end
    end
    
    def mark_bugged_commits( buggy_commits )
      buggy_commits.each do |commit|
        c = CommitStats::Commit.find_by_sha commit.sha
        c.bug! commit.bug if c
      end
    end
    
    def to_csv
      mark_bugged_commits gather_bugged_shas
      
      commits = CommitStats::Commit.find :all, :conditions => ["caused_bug IS NOT NULL"]
      FasterCSV.generate do |csv|
        csv << %w[SHA Revision CausedBug]
        
        commits.each do |commit|
          csv << [
            commit.sha,
            commit.svn_revision,
            commit.caused_bug
          ].map { |field| field.to_s }
        end
      end
    end
  end
end
