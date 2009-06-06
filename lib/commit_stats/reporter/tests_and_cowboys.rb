require "fastercsv"

module CommitStats::Reports
  class TestsAndCowboys
    def to_csv
      FasterCSV.generate do |csv|
        csv << %w[Date BugsCreated BuildsBroken TotalCommits TestcasesWritten Cowboy_Commits Untested_Commits]
        bugs = CommitStats::BugCount.find :all, :order => "date ASC"
        bugs.each do |bug_count|
          
          commits  = CommitStats::Commit.find( :all, :conditions => ["DATE(date) = ?", bug_count.date] )
          cowboys, untested = 0, 0
          commits.each do |commit|
            cowboys  += 1 if commit.cowboy?
            untested += 1 if commit.untested?
          end
          
          csv << [
            bug_count.date.strftime( "=DATE( %Y,%m,%d )" ),
            bug_count.bugs_created,
            CommitStats::BrokenBuild.count( :conditions => ["DATE(date) = ?", bug_count.date] ),
            CommitStats::Commit.count( :conditions => ["DATE(date) = ?", bug_count.date] ),
            CommitStats::Commit.sum( 'testcase_count', :conditions => ["DATE(date) = ?", bug_count.date] ),
            cowboys,
            untested
          ].map { |field| field.to_s }
        end
      end
    end
  end
end
