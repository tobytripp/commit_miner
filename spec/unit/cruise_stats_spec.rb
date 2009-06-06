require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )

module CommitStats
  describe "Cruise Statistics" do
    before :all do
      @cruise_report = File.read File.dirname(__FILE__) + "/../fixtures/cruise.html"
      @cruise_detail = File.read File.dirname(__FILE__) + "/../fixtures/cruise_fail_detail.html"
    end
    
    before :each do
      uri = URI::parse( "http://my.cruise.com" )
      
      stub( WWW::Mechanize ).new {
        agent = mock( Object.new )
        agent.get( "http://my.cruise.com/dashboard/project/list/all/my_project" ).yields(
          WWW::Mechanize::Page.new uri, { "content-type" => "text/html" }, @cruise_report
        )
        agent.get( "/dashboard/tab/build/detail/project/20090106033311" ).yields(
          WWW::Mechanize::Page.new uri, { "content-type" => "text/html" }, @cruise_detail
        )
        agent
      }
      
      @cruise_stats = CommitStats::Miner::CruiseControl.new "http://my.cruise.com", "my_project"
    end
    
    it "should read the data from the cruise dashboard" do
      @cruise_stats.generate_statistics
      BrokenBuild.count.should == 1
    end
  end
end