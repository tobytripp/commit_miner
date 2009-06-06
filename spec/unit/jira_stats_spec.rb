require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )
require "open-uri"

module CommitStats
  describe Miner::Jira do
    before :all do
      @jira_report = File.read File.dirname(__FILE__) + "/../fixtures/jira_stats.html"
    end
    
    before :each do
      @stats = Miner::Jira.new "http://my.jira.com"
      
      uri = URI::parse( "http://my.jira.com" )
      
      stub( WWW::Mechanize ).new {
        agent = stub( Object.new )
        agent.get( @stats.report_url ) {
          WWW::Mechanize::Page.new uri, { "content-type" => "text/html" }, @jira_report
        }
        agent
      }
    end
  
    it "should generate the proper Jira report URL" do
      @stats.report_url.should ==
        "http://my.jira.com/jira/secure/ConfigureReport.jspa?"\
        "cumulative=false&daysprevious=360&periodName=daily&"\
        "projectOrFilterId=project-10010&"\
        "reportKey=com.atlassian.jira.ext.charting%3Acreatedvsresolved-report&"\
        "selectedProjectId=10010&versionLabels=major"
    end
    
    it "should request the page and record the bug counts" do
      @stats.generate_statistics
      BugCount.count.should == 180
    end
  end
end
