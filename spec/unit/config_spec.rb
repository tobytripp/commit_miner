require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )

module CommitStats
  describe Configurator do
    before :each do
      @config = Configurator.load <<-EOS
        configurate do |config|
          config.cruise_url     = "http://cruise"
          config.jira_url       = "http://jira"
          config.git_repo       = "."
          config.cruise_project = "commit_stats"
        end
      EOS
    end
    
    it "should provide access to configuration variables specified" do
      @config.cruise_url.should == "http://cruise"
      @config.jira_url.should   == "http://jira"
    end
  end
end