if Rails.env.production?
  _redis_config = { :url => "#{Rails.configuration.redis_url}/12", :namespace => 'sidekiq' }

  Sidekiq.configure_server do |config|
    config.redis = _redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = _redis_config
  end
end