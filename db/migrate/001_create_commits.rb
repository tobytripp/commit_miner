class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table "commits", :force => true do |t|
      t.string   :author
      t.text     :changeset
      t.datetime :date
      t.string   :feature
      t.string   :pair
      t.string   :message
      t.string   :sha
      t.integer  :svn_revision
      t.integer  :testcase_count, :default => 0
    end
  end
  
  def self.down
    drop_table "commits"
  end
end