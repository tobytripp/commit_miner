# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "broken_builds", :force => true do |t|
    t.date     "date"
    t.integer  "svn_revision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bug_counts", :force => true do |t|
    t.date     "date"
    t.integer  "bugs_created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commits", :force => true do |t|
    t.string   "author"
    t.text     "changeset",      :limit => 10000000
    t.datetime "date"
    t.string   "feature"
    t.string   "pair1"
    t.string   "message"
    t.string   "sha"
    t.integer  "svn_revision"
    t.integer  "testcase_count",                     :default => 0
    t.string   "pair2"
    t.string   "caused_bug"
  end

end
