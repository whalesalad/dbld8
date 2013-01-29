source 'https://rubygems.org'

# Por Heroku
ruby "1.9.3"
gem 'foreman'

gem 'rails', '3.2.11'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'pg'
gem 'haml'
gem 'countries'
gem 'faker'
gem 'multi_json'
gem 'oj'
gem 'jbuilder'

# Postgres ext goodies
gem 'postgres_ext'

# GEO API Handling
gem 'rest-client'
gem 'json'

# Elasticsearch
gem 'kaminari'
gem 'tire'

# Facebook
gem 'koala'

# S3 // AWS
gem 'fog'

# Redis // Caching
gem 'redis'
gem 'redis-store'
gem 'redis-rails'

gem 'kgio'
gem 'dalli'

# Mixpanel
# gem 'mixpanel'

# Background Jobbin'
gem 'sidekiq'
gem 'slim'
gem 'sinatra', :require => nil

# gem 'resque', :require => "resque/server"

# Images, File Handling
# gem 'rmagick'
gem 'mini_magick'
gem 'carrierwave'

# Monitoring
gem 'asset_sync'

# Push Notifications
gem 'grocer'

# Gems used only for assets and not in production
group :assets do
  gem 'sass-rails',   '~> 3.2'
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
end

group :production do
  gem 'memcachier'
  gem 'unicorn'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'bullet'
  gem 'thin'
  gem 'quiet_assets'
  gem 'rspec-rails'
  gem 'cucumber'
  gem 'json_spec'
  gem 'pry-rails'
  gem 'annotate', :git => 'git://github.com/jeremyolliver/annotate_models.git', :branch => 'rake_compatibility'
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
end
