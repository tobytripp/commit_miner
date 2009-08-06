require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )

module CommitStats
  describe Report do
    before :each do
      @git    = mock( Miner::Git.new "." )
      @cruise = mock( Miner::CruiseControl.new "", "foo" )
      @jira   = mock( Miner::Jira.new "" )
    
      stub( Miner::Git  ).new { @git }
      stub( Miner::CruiseControl ).new { @cruise }
      stub( Miner::Jira ).new { @jira }

      Config = Configurator.new
      Config.git_repo = "."
      
      @report = Report.new
    end

    it "should call #gather_statistics on each statistic object" do
      [@cruise, @git, @jira].each { |stat| stat.gather_statistics }
      @report.generate
    end
  end
end
