require 'fog'
require 'socket'

desc "PostgreSQL Backup"
namespace :pg do
  def fog
    @fog ||= Fog::Storage.new({
      provider: Rails.configuration.fog['provider'],
      aws_access_key_id: Rails.configuration.fog["aws_access_key_id"],
      aws_secret_access_key: Rails.configuration.fog["aws_secret_access_key"]
    })
  end
    
  def backup_dir
    @backup_dir ||= fog.directories.get("dbld8-db-backup")
  end

  def send_to_amazon(path)
    backup_dir.files.create({
      key: File.basename(path),
      body: File.open("#{path}")
    })
  end

  def latest_backup
    backup_dir.files.last
  end

  def db_config
    @db_config ||= Rails.configuration.database_configuration[Rails.env]
  end

  def db_host
    db_config['host'] || 'localhost'
  end

  def pg_pass
    "PGPASSWORD=\"#{db_config['password']}\""
  end

  task :backup => :environment do
    t = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    
    backup_file = "/var/tmp/doubledate_#{t}_#{Socket.gethostname}_#{Rails.env}.pgdump"

    # Dump a compressed heroku-style backup
    sh "#{pg_pass} pg_dump -h #{db_host} -Fc --no-acl --no-owner #{db_config['database']} > #{backup_file}"

    # Push to S3
    send_to_amazon(backup_file)
    
    # Delete the tmp file
    File.delete(backup_file)
  end

  task :restore => :environment do
    latest = latest_backup

    puts "Fetching latest backup from S3..."
    local_backup = File.open("/var/tmp/#{latest.key}", "w")
    
    latest.body.force_encoding("utf-8")

    local_backup.write(latest.body)
    local_backup.close

    puts "Re-creating database: #{db_config['database']}..."
    Rake.application['db:drop'].invoke
    Rake.application['db:create'].invoke

    puts "Restoring #{latest.key} to #{db_config['database']} on #{db_host}..."
    exec "#{pg_pass} pg_restore -h #{db_host} --verbose --clean --no-acl --no-owner -d #{db_config['database']} #{local_backup.path}"
  end
end