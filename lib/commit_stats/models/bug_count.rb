module CommitStats
  class BugCount < ActiveRecord::Base
    before_create :update_if_exising_date
    
  protected
    def update_if_exising_date
      existing = self.class.find :all,
        :select => "id", :conditions => ["date = ?", self.date]
      self.class.destroy existing.map( &:id )
    end
  end
end
