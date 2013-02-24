set_default :elasticsearch_version, '0.20.5'

namespace :elasticsearch do
  desc "Install Java 7"
  task :install, roles: :search do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install openjdk-7-jre-headless"
  end
  after "deploy:install", "elasticsearch:install"

  # cd ~
  # sudo apt-get update
  # sudo apt-get install openjdk-7-jre-headless -y
  # 
  # wget https://github.com/elasticsearch/elasticsearch/archive/v0.20.1.tar.gz -O elasticsearch.tar.gz
  # tar -xf elasticsearch.tar.gz
  # rm elasticsearch.tar.gz
  # sudo mv elasticsearch-* elasticsearch
  # sudo mv elasticsearch /usr/local/share
  # 
  # curl -L http://github.com/elasticsearch/elasticsearch-servicewrapper/tarball/master | tar -xz
  # sudo mv *servicewrapper*/service /usr/local/share/elasticsearch/bin/
  # rm -Rf *servicewrapper*
  # sudo /usr/local/share/elasticsearch/bin/service/elasticsearch install
  # sudo ln -s `readlink -f /usr/local/share/elasticsearch/bin/service/elasticsearch` /usr/local/bin/rcelasticsearch
  # 
  # sudo service elasticsearch start
  # curl http://localhost:9200

  desc "Setup Elasticsearch initializer"
  # http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.5.tar.gz
  task :setup, roles: :search do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    template "unicorn_init.erb", "/tmp/unicorn_init"
    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/#{unicorn_init}"
    run "#{sudo} update-rc.d -f #{unicorn_init} defaults"
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service #{unicorn_init} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end
