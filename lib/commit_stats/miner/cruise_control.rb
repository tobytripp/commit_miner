#!/usr/bin/env ruby -KU
require "rubygems"
require "mechanize"

module CommitStats
  module Miner
    class CruiseControl
      def initialize( options={} )
        @url     = Config.cruise_url
        @project = Config.cruise_project
      end
  
      def generate_statistics
        puts "Generating Cruise Build statistics from #{@url} for #{@project}"
        agent = WWW::Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }

        agent.get( "#{@url}/dashboard/project/list/all/#{@project}" ) do |page|
          page.search( "//div[@class='failed build_profile']/a[1]" ).each do |build_detail|
            detail_href = build_detail["href"]
          
            unless detail_href.nil?
              date = DateTime.parse( detail_href.split("/").last ).strftime "%Y-%m-%d %H:%M:%S"
              agent.get( detail_href ) do |detail|
                revs = detail.search ".//div[@id='modifications']/table[@class='modifications']/tbody/tr[2]/td[1]"
              
                revs.each { |rev|
                  rev.inner_html =~ /rev[.] (\d+)/
                  BrokenBuild.create :date => date, :svn_revision => $1
                } unless revs.empty?
              end
            end
          end
        end
      end
      alias_method :gather_statistics, :generate_statistics
  
      def to_hash
        generate_statistics
      end
  
      def to_a
        generate_statistics.values.flatten
      end
  
      def to_s
        to_hash.inspect
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require File.expand_path( File.dirname(__FILE__) + "/../../commit_stats" )
  puts CommitStats::Miner::CruiseControl.new( CommitStats::Config.cruise_url ).to_s
end