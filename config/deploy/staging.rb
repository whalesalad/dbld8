# server "donner.dbld8.com", :web, :app, :search, :db, :primary => true
server "198.199.124.246", :web, :app, :search, :db, :primary => true

set :branch, "staging"
set :rails_env, "staging"

set_default(:postgresql_host, 'localhost')
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { "never fly without your wings" }
set_default(:postgresql_database) { "doubledate_staging" }

set :unicorn_workers, 2

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}