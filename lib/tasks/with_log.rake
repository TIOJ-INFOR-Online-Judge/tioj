task :with_log => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end