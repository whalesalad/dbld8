set_default(:unicorn_user) { user }
set_default(:unicorn_workers, 4)
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:unicorn_init) { "#{application}_unicorn" }

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    template "unicorn_init.erb", "/tmp/unicorn_init"
    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/#{unicorn_init}"
    run "#{sudo} update-rc.d -f #{unicorn_init} defaults"
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart upgrade].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service #{unicorn_init} #{command}"
    end
    # after "deploy:#{command}", "unicorn:#{command}"
  end
  after "deploy:restart", "unicorn:upgrade"
end