class AddASecondPairColumn < ActiveRecord::Migration
  def self.up
    rename_column :commits, :pair,  :pair1
    add_column    :commits, :pair2, :string
  end
  
  def self.down
    remove_column :commits, :pair2
    rename_column :commits, :pair1, :pair
  end
end