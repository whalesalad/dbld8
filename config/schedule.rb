set :output, "#{path}/log/cron.log"

every :minute, :roles => :app do
  command "script/librato"
end

every :hour, :roles => :cron do
  rake "dbld8:expire_engagements"  
end

every 4.hours, :roles => :cron do
  # run apn feedback worker
  runner "PushFeedbackWorker.perform_async"
  
  # Run a database backup
  rake "pg:backup"
end