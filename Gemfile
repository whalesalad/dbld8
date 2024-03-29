source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'haml'
gem 'countries'
gem 'rack-contrib'
gem 'rails-i18n'
gem 'unicorn'

# New Relic
gem 'newrelic_rpm'

# JSON
gem 'multi_json'
gem 'jbuilder'
gem 'oj'

# DB
gem 'pg'
gem 'activerecord-postgres-hstore'
gem 'postgres_ext'

# GEO API Handling
gem 'rest-client'

# Elasticsearch
gem 'kaminari'
gem 'tire'
gem 'tire-contrib'

# Facebook
gem 'koala'

# S3 // AWS
gem 'fog'

# Memcached
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

# Push Notifications
gem 'grocer'

# Apple purchase verification
gem 'venice'

gem 'whenever', require: false
gem 'asset_sync'

# Gems used only for assets and not in production
group :assets do
  gem 'sass-rails',   '~> 3.2'
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
  gem 'font-awesome-rails'
  gem 'bourbon'
  gem 'neat'
end

group :production do
  gem "lograge"
  gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"
end

group :development, :test do
  gem "lol_dba"
  gem "thin"
  gem "bullet"
  gem "quiet_assets"
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "json_spec"
  gem "pry-rails"
  gem "annotate", :git => "git://github.com/jeremyolliver/annotate_models.git", :branch => "rake_compatibility"
  gem "capistrano"
  gem "hipchat"
end

group :test do
  gem "capybara"
  gem "guard-rspec"
  gem "faker"
end
