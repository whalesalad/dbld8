source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'pg'
gem 'haml'
gem 'thin'
gem 'countries'

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

# Background Jobbin'
gem 'resque', :require => "resque/server"

# Images, File Handling
gem 'rmagick'
gem 'carrierwave'

# Monitoring
gem 'asset_sync'

# Gems used only for assets and not in production
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bootstrap-sass', '~> 2.1.1.0'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
end

group :development, :test do
  gem 'cucumber'
  gem 'json_spec'
  gem 'pry-rails'
  gem 'annotate', :git => 'git://github.com/jeremyolliver/annotate_models.git', :branch => 'rake_compatibility'
end