set_default :splunk_download_path, "/tmp/splunkforwarder.deb"
set_default :splunk_download_cmd, "wget -O #{splunk_download_path} 'http://www.splunk.com/page/download_track?file=5.0.2/universalforwarder/linux/splunkforwarder-5.0.2-149561-linux-2.6-intel.deb&ac=&wget=true&name=wget&typed=releases&elq=c027df9d-dab0-4128-8050-95fc9d81984a'"

set_default :spl_file, "stormforwarder_b3661cbe81a511e29d501231390e2541.spl"
set_default :splunk_spl, File.read(File.expand_path("../templates/#{spl_file}", __FILE__))

namespace :splunk do
  desc "Install the Splunk forwarder"
  task :install do
    run splunk_download_cmd
    run "#{sudo} dpkg -i #{splunk_download_path}"
    put splunk_spl
  end
  after "deploy:install", "redis:install"

  %w[start stop restart].each do |command|
    desc "#{command} redis-server"
    task command, roles: :search do
      run "#{sudo} service redis-server #{command}"
    end
  end

  task :flush, roles: :search do
    run "redis-cli flushall"
  end
end
