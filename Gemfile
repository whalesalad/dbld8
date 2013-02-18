source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'haml'
gem 'countries'
gem 'faker'
gem 'thin'
gem 'typhoeus'

# JSON
gem 'multi_json'
gem 'oj'
gem 'jbuilder'

# DB
gem 'pg'
gem 'activerecord-postgres-hstore'
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

# Memcached
gem 'kgio'
gem 'dalli'

# Mixpanel // Segment.io
gem 'analytics-ruby'

# Background Jobbin'
gem 'sidekiq'
gem 'slim'
gem 'sinatra', :require => nil

# Images, File Handling
gem 'mini_magick'
gem 'carrierwave'

# Assets
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
  gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"
end

group :development, :test do
  gem 'bullet'
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
