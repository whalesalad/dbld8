# set :application, "set your application name here"
# set :repository,  "set your repository location here"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

require "bundler/capistrano"
require "sidekiq/capistrano"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

load "config/recipes/base"
load "config/recipes/rbenv"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/postgresql"
load "config/recipes/nodejs"
load "config/recipes/redis"
load "config/recipes/elasticsearch"
load "config/recipes/check"

server "rudolph.dbld8.com", :web, :app, :db, primary: true
server "comet.dbld8.com", :web, :app
server "blitzen.dbld8.com", :search, :db, no_release: true
# server "donner.dbld8.com", :web, :app, :search

set :user, "doubledate"
set :application, "doubledate"
set :deploy_to, "/srv/doubledate"
set :deploy_via, :remote_cache
set :use_sudo, false

# set :scm, "git"
set :branch, "master"
set :repository, "git@github.com:whalesalad/dbld8.git"

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }
set :default_shell, "/bin/bash"

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

after "deploy", "deploy:cleanup" # keep only the last 5 releases