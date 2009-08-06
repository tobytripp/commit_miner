require 'rubygems'
require 'spec'
require 'activerecord'

ENV["DB_ENV"] = ENV["APP_ENV"] = "test"

$LOAD_PATH <<  File.expand_path( File.dirname(__FILE__) + "/../lib" )
require "commit_stats"

begin
  old_stream = STDOUT.dup
  STDOUT.reopen '/dev/null'
  STDOUT.sync = true
  load File.dirname(__FILE__) + "/../db/schema.rb"
ensure
  STDOUT.reopen old_stream
end

Spec::Runner.configure do |config|
  config.before :each do
    unless ActiveRecord::Base.connection.open_transactions > 0
      ActiveRecord::Base.connection.increment_open_transactions
      ActiveRecord::Base.connection.transaction_joinable = false
      ActiveRecord::Base.connection.begin_db_transaction
    else
      warn "Only one open transaction allowed (#{__FILE__}:#{__LINE__})" 
    end
  end
  
  config.after :each do
    if ActiveRecord::Base.connection.open_transactions != 0
      ActiveRecord::Base.connection.rollback_db_transaction
      ActiveRecord::Base.connection.decrement_open_transactions
    end
    ActiveRecord::Base.clear_active_connections!
  end
  
  config.mock_with :rr
end
