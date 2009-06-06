class IncreaseChangesetSize < ActiveRecord::Migration
  def self.up
    change_column :commits, :changeset, :text, :limit => 10_000_000
  end
  
  def self.down
    change_column :commits, :changeset, :text
  end
end
