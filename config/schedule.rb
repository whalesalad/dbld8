set :output, "#{path}/log/cron.log"

# every :hour, :roles => :cron do
  
# end

every 4.hours, :roles => :cron do
  # run apn feedback worker
  runner "PushFeedbackWorker.perform_async"
  
  # Run a database backup
  rake "pg:backup"
end