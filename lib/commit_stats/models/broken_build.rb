module CommitStats
  class BrokenBuild < ActiveRecord::Base
    validates_uniqueness_of :svn_revision
  end
end
