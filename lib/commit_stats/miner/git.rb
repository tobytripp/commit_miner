#!/usr/bin/env ruby -KU
require "rubygems"
require 'git'

module CommitStats
  module Miner
    class Git
      DEFAULT_MINER_DATE = "2 years ago"
      
      def initialize( options={} )
        @git = ::Git.open Config.git_repo
        @since_date = determine_start_date options[:since_date]
        
        @log = @git.log( 100000 ).since @since_date
      end
    
      def gather_statistics
        puts "Gathering commit statistics for Git repo at #{@git.dir.path}, since #{@since_date}"
        puts "Found #{@log.size.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")} log entries"
        
        puts "Processing…"
        @log.each do |object|
          commit = Commit.new
        
          commit.sha    = object.sha
          commit.author = object.author.name
          commit.date   = object.date
        
          message = object.message
          message =~ /^\s*\[(.+)\]\s*([^:-]+)[:-]\s*(.*)$/
          commit.feature = $1
          commit.pair1, commit.pair2 = $2.nil? ? ["",""] : $2.split( /,|\/|\\/ )
          commit.message = $3 || object.message
        
          message =~ /git-svn-id:?[^@]+@([0-9]+)/
          commit.svn_revision = $1
        
          begin
            diff = object.diff_parent
            commit.changeset = diff.stats[:files].keys
            commit.diff = diff.patch
            
            commit.save ? print( '.' ) : print( '-' )
            $stdout.flush
          rescue ::Git::GitExecuteError => e
            puts "problem analyzing diff for commit: #{commit}"
            puts e.message
          end
        end
        puts "Done!"
      end

      def determine_start_date( given_date=nil )
        return given_date if given_date
        
        last_commit = Commit.most_recent
        last_commit ? last_commit.date.to_s : DEFAULT_MINER_DATE
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require File.expand_path( File.dirname(__FILE__) + "/../../../commit_stats" )
  $stdout.sync = true
  
  stats = CommitStats::Miner::Git.new CommitStats::Config.git_repo
  stats.gather_statistics
  puts
end
