require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )
require "open-uri"
require "ostruct"

class Hash
  def to_query
    self.map { |k, v| "#{k}=#{v}" }.sort.join "&"
  end
end

module CommitStats
  describe Miner::Jira do
    before :all do
      @jira_report = File.read File.dirname(__FILE__) +
        "/../fixtures/jira_stats.html"
    end
    
    before :each do
      Config.jira_url = "http://my.jira.com"
      Config.jira_project_id = "1001"
      @stats = Miner::Jira.new
      
      @mech = OpenStruct.new :html_parser => Nokogiri::HTML
      
      agent = stub( WWW::Mechanize.new )
      agent.get do
        page = WWW::Mechanize::Page.new URI.parse( Config.jira_url ),
          { "content-type" => "text/html" },
          @jira_report
        page.mech = @mech
        page
      end
      
      stub( WWW::Mechanize ).new { agent }
    end
  
    it "should generate the proper Jira report URL" do
      query = {
        :cumulative        => false,
        :daysprevious      => 360,
        :periodName        => 'daily',
        :projectOrFilterId => 'project-1001',
        :reportKey         =>
          'com.atlassian.jira.ext.charting%3Acreatedvsresolved-report',
        :selectedProjectId => 1001,
        :versionLabels     => 'major'
      }.to_query

      URI.parse( @stats.report_url ).request_uri.should ==
        "/jira/secure/ConfigureReport.jspa?#{query}"
    end
    
    it "should request the page and record the bug counts" do
      @stats.generate_statistics
      BugCount.count.should == 180
    end
  end
end
