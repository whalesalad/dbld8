set_default(:puma_threads, "8:32")
set_default(:puma_pid) { "#{current_path}/tmp/pids/puma.pid" }
set_default(:puma_config) { "#{shared_path}/config/puma.rb" }
set_default(:puma_log) { "#{shared_path}/log/puma.log" }
set_default(:puma_init) { "#{application}_puma" }

set_default(:puma_cmd) { "#{fetch(:bundle_cmd, 'bundle')} exec puma" }
set_default(:pumactl_cmd) { "#{fetch(:bundle_cmd, 'bundle')} exec pumactl" }
set_default(:puma_state) { "#{shared_path}/sockets/puma.state" }

# after "deploy:setup", "puma:setup"

namespace :puma do
  # desc "Setup Puma initializer and app configuration"
  # task :setup, roles: :app do
  #   run "mkdir -p #{shared_path}/config"
  #   template "puma.rb.erb", puma_config
  #   template "puma_init.erb", "/tmp/puma_init"
  #   run "chmod +x /tmp/puma_init"
  #   run "#{sudo} mv /tmp/puma_init /etc/init.d/#{puma_init}"
  #   run "#{sudo} update-rc.d -f #{puma_init} defaults"
  # end
  
  desc 'Start Puma'
  task :start, roles: :app do
    puma_env = fetch(:rack_env, fetch(:rails_env, 'production'))
    run "cd #{current_path} && #{fetch(:puma_cmd)} -q -d -e #{puma_env} -b 'unix://#{shared_path}/sockets/puma.sock' -S #{fetch(:puma_state)} --control 'unix://#{shared_path}/sockets/pumactl.sock'", :pty => false
  end

  desc 'Stop Puma'
  task :stop, roles: :app do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} stop"
  end

  desc 'Restart Puma'
  task :restart, roles: :app do
    run "cd #{current_path} && #{fetch(:pumactl_cmd)} -S #{fetch(:puma_state)} restart"
  end

  # after "deploy:restart", "unicorn:upgrade"

end