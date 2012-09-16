CarrierWave.configure do |config|
  config.cache_dir = Rails.root.join("tmp", "uploads")
  config.root      = Rails.root.join("tmp")

  config.fog_credentials = {
    :provider               => "AWS",
    :aws_access_key_id      => ENV["S3_KEY"],
    :aws_secret_access_key  => ENV["S3_SECRET"],
  }

  config.fog_directory  = "static.dbld8.com"
  config.fog_host       = "http://static.dbld8.com"
  config.fog_public     = true
  config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
end