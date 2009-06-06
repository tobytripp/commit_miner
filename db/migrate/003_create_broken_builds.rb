class CreateBrokenBuilds < ActiveRecord::Migration
  def self.up
    create_table "broken_builds", :force => true do |t|
      t.date    :date
      t.integer :svn_revision
      t.timestamps
    end
  end
  
  def self.down
    drop_table "broken_builds"
  end
end