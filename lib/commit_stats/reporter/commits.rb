require "fastercsv"

module CommitStats::Reports
  class Commits
    def to_csv
      FasterCSV.generate do |csv|
        csv << %w[Date Revision Pair UserName Cowboy? Untested? Message]
        CommitStats::Commit.find( :all, :order => "date ASC" ).each do |commit|
          csv << [
            commit.date.strftime( "=DATE( %Y,%m,%d )" ),
            commit.svn_revision,
            commit.pair,
            commit.author,
            commit.cowboy? ? 1 : 0,
            commit.tested? ? 0 : 1,
            commit.message
          ].map { |field| field.to_s }
        end
      end
    end
  end
end
