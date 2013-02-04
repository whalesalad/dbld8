# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 3

preload_app true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  defined?(AnalyticsRuby) and
    Analytics.init(
      secret: Rails.configuration.segment_io_secret,
      on_error: Rails.configuration.segment_io_error
    )
end

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 20

listen ENV['PORT']
