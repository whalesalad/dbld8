if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { :url => 'redis://blitzen:6379/12', :namespace => 'sidekiq' }
  end
end