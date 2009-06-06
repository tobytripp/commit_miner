#!/usr/bin/env ruby -KU
require "rubygems"
require "mechanize"

module CommitStats
  module Miner
    class Jira
      REPORT_PATH = "/jira/secure/ConfigureReport.jspa"
      REPORT_OPTIONS = {
        :projectOrFilterId => "project-10010",
        :periodName        => "daily",
        :daysprevious      => "360", 
        :cumulative        => "false", 
        :versionLabels     => "major",
        :selectedProjectId => "10010", 
        :reportKey => "com.atlassian.jira.ext.charting%3Acreatedvsresolved-report"
      }
  
      def REPORT_OPTIONS.to_query
        "?" + map { |key, value| "#{key}=#{value}" }.sort.join( "&" )
      end
  
      attr_reader :report_url

      def initialize( jira_url )
        @report_url = jira_url + REPORT_PATH + REPORT_OPTIONS.to_query
      end
  
      def generate_statistics
        agent = WWW::Mechanize.new
        page  = agent.get @report_url

        page.search( "#createdvsresolved-report-datatable tr" ).each do |element|
          next if element.children.first.content == "Period"
          date = Date.parse element.children.first.content
          created = element.css( "td" ).first.content.to_i
          BugCount.create :date => date, :bugs_created => created
        end
        self
      end
      alias_method :gather_statistics, :generate_statistics
  
      def to_hash
        Hash[ created_by_date ]
      end
  
      def to_a
        created_by_date.map { |date, count| [date.strftime( '%Y-%m-%d' ), count] }
      end
  
      def to_s
        BugCount.find( :all, :order => "date ASC" ).map { |bug_count|
          "#{bug_count.date}, #{bug_count.bugs_created}"
        }.join "\n"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require File.expand_path( File.dirname(__FILE__) + "/../../commit_stats" )
  
  stats = CommitStats::Miner::Jira.new CommitStats::Config.jira_url
  stats.generate_statistics
  puts stats.to_s
end
