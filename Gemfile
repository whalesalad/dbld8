source 'https://rubygems.org'

gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => '3-2-stable'

gem 'pg'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'annotate', :git => 'git://github.com/jeremyolliver/annotate_models.git', :branch => 'rake_compatibility'

gem 'haml'

# Gems used only for assets and not in production
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
  gem 'bootstrap-sass', '~> 2.0.4.1'
end

group :production do
  gem 'unicorn'
end

group :development, :test do
  gem 'pry-rails'
  gem 'thin'
end

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
