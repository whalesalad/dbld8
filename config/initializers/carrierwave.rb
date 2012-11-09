fog_config = YAML.load_file(Rails.root.join("config/fog.yml"))[Rails.env]

CarrierWave.configure do |config|
  config.cache_dir = Rails.root.join("tmp", "uploads")
  config.root      = Rails.root.join("tmp")

  config.fog_credentials = {
    :provider               => Rails.configuration.fog["fog_provider"],
    :aws_access_key_id      => Rails.configuration.fog["aws_access_key_id"],
    :aws_secret_access_key  => Rails.configuration.fog["aws_secret_access_key"],
  }

  config.fog_directory  = Rails.configuration.fog['fog_directory']
  config.asset_host     = "http://#{Rails.configuration.fog['fog_directory']}"
  config.fog_public     = true
  config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
end