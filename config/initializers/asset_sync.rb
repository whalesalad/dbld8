AssetSync.configure do |config|
  config.fog_provider = Rails.configuration.fog["provider"]
  config.fog_directory = Rails.configuration.fog['fog_directory']
  config.aws_access_key_id = Rails.configuration.fog["aws_access_key_id"]
  config.aws_secret_access_key = Rails.configuration.fog["aws_secret_access_key"]
end