set_default :elasticsearch_version, '0.20.5'
set_default :elasticsearch_download_path, "http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{elasticsearch_version}.tar.gz"
set_default :elasticsearch_path, "/usr/local/share/elasticsearch"

namespace :elasticsearch do
  desc "Install Java 7"
  task :install, roles: :search do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install openjdk-7-jre-headless"
  end
  after "deploy:install", "elasticsearch:install"

  desc "Download & Setup Elasticsearch"
  task :setup, roles: :search do
    run "wget #{elasticsearch_download_path} -O /tmp/elasticsearch.tar.gz"
    run "tar -xvf /tmp/elasticsearch.tar.gz"
    run "#{sudo} mv elasticsearch-* #{elasticsearch_path}"

    run "cd /tmp"
    run "curl -L http://github.com/elasticsearch/elasticsearch-servicewrapper/tarball/master | tar -xvz"
    run "#{sudo} mv *servicewrapper*/service #{elasticsearch_path}/bin/"
    run "#{sudo} #{elasticsearch_path}/bin/service/elasticsearch install"
    run "#{sudo} ln -s `readlink -f #{elasticsearch_path}/bin/service/elasticsearch` /usr/local/bin/rcelasticsearch"
  end
  after "deploy:setup", "elasticsearch:setup"

  %w[start stop restart].each do |command|
    desc "#{command} elasticsearch"
    task command, roles: :search do
      run "service elasticsearch #{command}"
    end
    # after "deploy:#{command}", "elasticsearch:#{command}"
  end

  # desc "Reindex "

  task :reindex, roles: :app do
    run_rake "environment tire:import CLASS=Activity FORCE=true"
  end
end
