namespace :memcached do
  desc "Install latest stable release of redis"
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install memcached"
  end
  after "deploy:install", "memcached:install"

  %w[start stop restart].each do |command|
    desc "#{command} memcached"
    task command, roles: :app do
      run "#{sudo} service memcached #{command}"
    end
  end
end
