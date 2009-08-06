require File.expand_path( File.dirname(__FILE__) + "/../spec_helper" )
require "ostruct"

module CommitStats
  describe Miner::Git do
    before :each do
      log = TEST_DATA
      mock( git = Object.new ).log( 100000 ) do
        mock!.since( "2 years ago" ) { log }
      end
      stub( git ).dir { stub( Object.new ).path {'.'} }
      
      mock( ::Git ).open( '.' ) { git }
      
      @commits = Miner::Git.new( '.' ).gather_statistics
    end
    
    describe "parse_log" do
      it "should create a Commit instance for each commit record" do
        Commit.count.should == 2
      end
      
      it "should count testcases for each commit" do
        commit = Commit.find :first,
          :conditions => ["date = ?", "2009-03-05 16:22:25"]
        commit.testcase_count.should == 1
      end
    end
  end
end

PATCH1 = <<EOS
diff --git a/bin/commit_stats.rb b/bin/commit_stats.rb
new file mode 100644
index 0000000..f9e6b4b
--- /dev/null
+++ b/bin/commit_stats.rb
@@ -0,0 +1,36 @@
+#!/usr/bin/env ruby -wKU
+# == Synopsis
+#   Gather statistics from git diff data
+#
+# == Usage
+#   commit_stats.rb [-h|--help] [-o|--output PATH] [-s|--since DATE] [LOG_FILE]...
EOS

PATCH2 = <<EOS
diff --git a/spec/git_stats_spec.rb b/spec/git_stats_spec.rb
new file mode 100644
index 0000000..cbd0d72
--- /dev/null
+++ b/spec/git_stats_spec.rb
@@ -0,0 +1,35 @@
+require File.dirname(__FILE__) + "/spec_helper"
+
+describe GitStatistics do
+  before :each do
+    @stats = GitStatistics.new
+  end
+
+  describe "parse_log" do
+    it "should create a Commit instance for each commit record" do
-    it "shouldn't do anything useful" do
+      commits = @stats.parse_log TEST_DATA
+      commits.size.should == 1
+    end
+  end
+end
EOS

TEST_DATA = [
  OpenStruct.new(
    :sha => "a734274a7fc0a0b0413322a869ac73cb55ee6e8a",
    :author => OpenStruct.new( :name => "Toby" ),
    :date => "Wed Mar 4 16:14:13 2009 -0600",
    :message => "[Git Stats] Toby/Rubber Ducky: Initial commit.",
    :diff_parent => OpenStruct.new(
      :stats => {
        :files => { "file1" => "", "file2" => "" }
      },
      :patch => PATCH1
    )
  ),
  
  OpenStruct.new(
    :sha => "643e36fffe5b45cdbe32fc4102da001c3950734c",
    :author => OpenStruct.new( :name => "Bob" ),
    :date => "Thu Mar 5 16:22:25 2009 -0600",
    :message => "[Git Stats] Toby: First Spec!",
    :diff_parent => OpenStruct.new(
      :stats => {
        :files => { "file3" => "", "file2" => "" }
      },
      :patch => PATCH2
    )
  )
]
