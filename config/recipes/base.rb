def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def remote_file_exists?(full_path)
  'true' == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties curl git build-essential tklib zlib1g-dev libssl-dev libreadline-gplv2-dev libxml2 libxml2-dev libxslt1-dev"
    run "#{sudo} mkdir -p #{deploy_to}"
    run "#{sudo} chown #{user}:admin #{deploy_to}"
  end
end
