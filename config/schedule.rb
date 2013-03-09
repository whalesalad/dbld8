set :output, "#{path}/log/cron.log"

every :hour, :roles => :db do
  # run apn feedback worker
  runner "PushFeedbackWorker.perform_async"

  # Run a database backup
  rake "pg:backup"
end