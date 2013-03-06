require 'fog'
require 'socket'

desc "PostgreSQL Backup"
namespace :pg do
  task :backup => :environment do
    t = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    
    backup_file = "/var/tmp/doubledate_#{t}_#{Socket.gethostname}.pgdump"

    db_config = Rails.configuration.database_configuration[Rails.env]

    db_host = db_config['host'] || 'localhost'

    # Dump a compressed heroku-style backup
    sh "pg_dump -h #{db_host} -Fc --no-acl --no-owner #{db_config['database']} > #{backup_file}"

    # Push to S3
    send_to_amazon(backup_file)
    
    # Delete the tmp file
    File.delete(backup_file)
  end

  def send_to_amazon(path)
    fog = Fog::Storage.new({
      provider: Rails.configuration.fog['provider'],
      aws_access_key_id: Rails.configuration.fog["aws_access_key_id"],
      aws_secret_access_key: Rails.configuration.fog["aws_secret_access_key"]
    })
    
    directory = fog.directories.get("dbld8-db-backup")

    directory.files.create({
      key: File.basename(path),
      body: File.open("#{path}")
    })
  end
end