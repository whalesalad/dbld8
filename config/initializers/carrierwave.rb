CarrierWave.configure do |config|
  config.cache_dir = Rails.root.join("tmp", "uploads")
  config.root      = Rails.root.join("tmp")

  config.fog_credentials = {
    :provider               => "AWS",
    :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"],
    :aws_secret_access_key  => ENV["AWS_SECRET_ACCESS_KEY"],
  }

  config.fog_directory  = ENV["FOG_DIRECTORY"]
  config.asset_host     = "http://#{ENV["FOG_DIRECTORY"]}"
  config.fog_public     = true
  config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
end