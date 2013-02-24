namespace :redis do
  desc "Install latest stable release of redis"
  task :install, roles: :app do
    run "#{sudo} apt-add-repository -y ppa:chris-lea/redis-server"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install redis-server"
  end
  after "deploy:install", "redis:install"

  %w[start stop restart].each do |command|
    desc "#{command} redis-server"
    task command, roles: :web do
      run "#{sudo} service redis-server #{command}"
    end
  end

  task :flush_cache, roles: :app do
    run "redis-cli flushall"
  end
  after "deploy", "redis:flush_cache"
end
