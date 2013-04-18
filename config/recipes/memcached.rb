set_default(:memcached_memory, 128)
set_default(:memcached_log) { "#{shared_path}/log/memcached.log" }

namespace :memcached do
  desc "Install latest stable release of redis"
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install memcached"
  end
  after "deploy:install", "memcached:install"

  desc "Setup Memcached configuration"
  task :setup, roles: :app do
    template "memcached.conf.erb", "/tmp/memcached.conf"
    run "#{sudo} mv /tmp/memcached.conf /etc/memcached.conf"
  end
  after "memcached:setup", "memcached:restart"

  %w[start stop restart].each do |command|
    desc "#{command} memcached"
    task command, roles: :app do
      run "#{sudo} service memcached #{command}"
    end
  end

  desc "Get the stats of memcached."
  task :stats, roles: :app do
    run "echo stats | nc 127.0.0.1 11211"
  end

  desc "Clear the memcached caches."
  task :flush, roles: :app do
    run "echo 'flush_all' | nc localhost 11211"
  end
end
