class AddCausedBugColumn < ActiveRecord::Migration
  def self.up
    add_column    :commits, :caused_bug, :boolean
  end
  
  def self.down
    remove_column :commits, :caused_bug
  end
end
