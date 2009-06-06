#!/usr/bin/env ruby -KU
require "rubygems"
require 'git'

module CommitStats
  module Miner
    class Git
      def initialize( repo_path, since_date="2 months ago" )
        @git = ::Git.open repo_path
        @log = @git.log.since since_date
      end
    
      def gather_statistics
        @log.each do |object|
          commit = Commit.new
        
          commit.sha    = object.sha
          commit.author = object.author.name
          commit.date   = object.date
        
          message = object.message
          message =~ /^\s*\[(.+)\]\s*([^:-]+)[:-]\s*(.*)$/
          commit.feature = $1
          commit.pair    = $2
          commit.message = $3 || object.message
        
          message =~ /git-svn-id:?[^@]+@([0-9]+)/
          commit.svn_revision = $1
        
          diff = object.diff_parent
          commit.changeset = diff.stats[:files].keys
          commit.diff = diff.patch
        
          commit.save
        end
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