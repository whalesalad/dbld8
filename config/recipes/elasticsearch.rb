set_default :elasticsearch_version, '0.20.6'
set_default :elasticsearch_deb, "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{elasticsearch_version}.deb"

namespace :elasticsearch do
  desc "Install Java 7"
  task :install, roles: :search do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install openjdk-7-jre-headless"
  end
  after "deploy:install", "elasticsearch:install"

  desc "Download & Setup Elasticsearch"
  task :setup, roles: :search do
    run "wget #{elasticsearch_deb} -O /tmp/elasticsearch.deb"
    run "#{sudo} dpkg -i /tmp/elasticsearch.deb"
  end
  after "deploy:setup", "elasticsearch:setup"

  %w[start stop restart].each do |command|
    desc "#{command} elasticsearch"
    task command, roles: :search do
      run "service elasticsearch #{command}"
    end
  end

  desc "Reindex"
  task :reindex, roles: :app do
    run_rake "environment tire:import CLASS=Activity FORCE=true"
    run_rake "environment tire:import CLASS=Location FORCE=true"
  end
end
