class CreateBugCounts < ActiveRecord::Migration
  def self.up
    create_table "bug_counts", :force => true do |t|
      t.date    :date
      t.integer :bugs_created
      t.timestamps
    end
  end
  
  def self.down
    drop_table "bug_counts"
  end
end