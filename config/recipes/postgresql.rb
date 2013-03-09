db_config = Rails.configuration.database_configuration[Rails.env]

set_default(:postgresql_host, db_config['host'] || 'localhost')
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { db_config['password'] }
set_default(:postgresql_database) { db_config['database'] }

namespace :postgresql do
  desc "Install PostgreSQL client on web servers"
  task :install_client, roles: :web do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql-client-9.1 libpq-dev"
  end
  after "deploy:install", "postgresql:install_client"

  desc "Setup pgpass file"
  task :pgpass, roles: :app do
    # hostname:port:database:username:password 
    # template "nginx.erb", "/tmp/nginx_conf"
    # run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
    # run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
  end

  # desc "Install the latest stable release of PostgreSQL."
  # task :install, roles: :db, only: {primary: true} do
  #   run "#{sudo} add-apt-repository ppa:pitti/postgresql"
  #   run "#{sudo} apt-get -y update"
  #   run "#{sudo} apt-get -y install postgresql libpq-dev"
  # end
  # after "deploy:install", "postgresql:install"

  # desc "Create a database for this application."
  # task :create_database, roles: :db, only: {primary: true} do
  #   run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
  #   run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  # end
  # after "deploy:setup", "postgresql:create_database"

  # desc "Generate the database.yml configuration file."
  # task :setup, roles: :app do
  #   run "mkdir -p #{shared_path}/config"
  #   template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  # end
  # after "deploy:setup", "postgresql:setup"

  # desc "Symlink the database.yml file into latest release"
  # task :symlink, roles: :app do
  #   run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  # end
  # after "deploy:finalize_update", "postgresql:symlink"
end