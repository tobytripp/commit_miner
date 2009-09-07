require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )

module CommitStats
  describe Report do
    before :each do
      Config.jira_url = "jira.com"
      Config.jira_project_id = "1001"
      Config.git_repo = "."
      
      @git    = mock( Miner::Git.new "." )
      @cruise = mock( Miner::CruiseControl.new )
      @jira   = mock( Miner::Jira.new "" )
    
      stub( Miner::Git  ).new { @git }
      stub( Miner::Jira ).new { @jira }
      stub( Miner::CruiseControl ).new { @cruise }
      
      @report = Report.new :multiprocess => false
    end

    it "should call #gather_statistics on each statistic object" do
      [@cruise, @git, @jira].each { |stat| stat.gather_statistics }
      @report.generate
    end
  end
end
