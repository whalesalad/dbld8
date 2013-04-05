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

def run_rake(task, options={}, &block)
  rake = fetch(:rake, 'rake')
  rails_env = fetch(:rails_env, 'production')
  command = "cd #{latest_release} && #{rake} #{task} RAILS_ENV=#{rails_env}"
  run(command, options, &block)
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties software-properties-common curl libcurl4-openssl-dev git build-essential tklib zlib1g-dev libssl-dev libreadline-gplv2-dev libxml2 libxml2-dev libxslt1-dev imagemagick"
    run "#{sudo} mkdir -p #{deploy_to}"
    run "#{sudo} chown #{user}:admin #{deploy_to}"
  end
end

desc "Get free memory on all servers"
task :free do
  run "free -m"
end

desc "tail production log files" 
task :tail, :roles => :app do
  trap("INT") { puts 'Interupted'; exit 0; }
  run "tail -f #{shared_path}/log/unicorn.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err
  end
end

desc "Gimme dat uname bro"
task :uname do
  run "uname -a"
end