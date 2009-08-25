class ChangeCausedBugColumn < ActiveRecord::Migration
  def self.up
    change_column :commits, :caused_bug, :string
  end
  
  def self.down
    change_column :commits, :caused_bug, :boolean
  end
end
