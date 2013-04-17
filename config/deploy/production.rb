server "rudolph.dbld8.com", :web, :app, :db, primary: true
server "comet.dbld8.com", :web, :app
server "blitzen.dbld8.com", :search, :db, no_release: true

role :cron, 'rudolph.dbld8.com'

set :branch, "master"

set_default(:postgresql_host, 'blitzen')
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { "never fly without your wings" }
set_default(:postgresql_database) { "doubledate" }