require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )

module CommitStats
  describe Commit do
    
    before :each do
      Commit.create!(
        :author         => "joe",
        :sha            => "a734274a7fc0a0b0413322a869ac73cb55ee6e8a",
        :date           => DateTime.parse( "Wed Mar 4 16:14:13 2009 -0600" ),
        :feature        => "Some Stuff",
        :pair           => "Bob/Sally",
        :svn_revision   => 40123,
        :diff           => "+def test_case\n+ it 'should be tested'"
      )
      
      Commit.create!(
        :author         => "bob",
        :sha            => "a734274a7fc0a0b0413322a869ac73cb55ee6e8b",
        :date           => DateTime.parse( "Wed Mar 3 16:14:13 2009 -0600" ),
        :feature        => "Some Stuff",
        :pair           => "Joe/Wally",
        :svn_revision   => 40124,
        :diff           => "- it 'used to be tested'"
      )
    end
    
    it "should save the records for later retrieval" do
      Commit.count.should == 2
    end
    
    it "should provide a way to get the total testcases" do
      Commit.total_testcases.should == 2
    end
    
    it "should expose the changeset as an Array" do
      commit = Commit.new
      commit.changeset << "new/change.rb"
    end
    
    it "should default the testcase count to zero" do
      Commit.new.testcase_count.should == 0
    end
    
    it "should accept the addition of diff lines" do
      commit = Commit.new
      commit.diff << "a line of diffiness"
      
      commit.diff.should == "a line of diffiness"
    end
  end
end