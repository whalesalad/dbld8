# HIPCHAT
# require 'hipchat/capistrano'
# set :hipchat_token, "ebcfbcc0b86138e2d0e4e563cb553e"
# set :hipchat_room_name, "DoubleDate"
# set :hipchat_announce, false
# set :hipchat_color, 'green'
# set :hipchat_failed_color, 'red'

set :whenever_roles, [:cron, :app]
set :whenever_command, "bundle exec whenever"

set :stages, %w(production staging)
set :default_stage, "staging"

require "bundler/capistrano"
require "sidekiq/capistrano"
require "whenever/capistrano"
require "capistrano/ext/multistage"

load "config/recipes/base"
load "config/recipes/rbenv"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/postgresql"
load "config/recipes/nodejs"
load "config/recipes/redis"
load "config/recipes/elasticsearch"
load "config/recipes/check"

set :user, "doubledate"
set :application, "doubledate"
set :deploy_to, "/srv/doubledate"
set :deploy_via, :remote_cache
set :use_sudo, false

set :branch, "master"
set :repository, "git@github.com:whalesalad/dbld8.git"

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }
set :default_shell, "/bin/bash"

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

after "deploy", "deploy:cleanup" # keep only the last 5 releases