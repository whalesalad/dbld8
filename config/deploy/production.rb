server "rudolph.dbld8.com", :web, :app, :db, primary: true
server "comet.dbld8.com", :web, :app
server "blitzen.dbld8.com", :search, :db, no_release: true

role :cron, 'rudolph.dbld8.com'

set :branch, "master"