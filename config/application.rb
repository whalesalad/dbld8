require File.expand_path('../boot', __FILE__)

require 'socket'
require 'rails/all'
# require "active_record/railtie"
# require "action_controller/railtie"
# require "action_mailer/railtie"
# require "active_resource/railtie"
# require "sprockets/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module DoubleDate
  class Application < Rails::Application
    # config.middleware.delete ActionDispatch::Flash
    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Session::CookieStore
    config.middleware.delete ActionDispatch::BestStandardsSupport
    config.middleware.use Rack::Locale
    config.middleware.use Rack::Deflater

    config.hostname = Socket.gethostname

    # used in urls like dbld8://wings/12
    config.ios_prefix = 'dbld8'

    config.app_id = "591235706"
    config.app_slug = "doubledate"
    config.app_store_url = "https://itunes.apple.com/us/app/doubledate-social-dating-meet/id591235706?ls=1&mt=8"

    config.fog = YAML.load_file(Rails.root.join("config/fog.yml"))[Rails.env]

    # Foursquare API
    config.foursquare_client_id = ENV['FOURSQUARE_CLIENT_ID']
    config.foursquare_client_secret = ENV['FOURSQUARE_CLIENT_SECRET']

    # Geonames API
    config.geonames_username = "whalesalad"

    # APN (Push Notifications)
    config.apn_mode = ENV['APN_MODE'] || Rails.env
    config.apn_gateway = "gateway.push.apple.com"
    config.apn_feedback = "feedback.push.apple.com"

    if config.apn_mode == 'development'
      config.apn_gateway = "gateway.sandbox.push.apple.com"
      config.apn_feedback = "feedback.sandbox.push.apple.com"
    end

    # Segment.io // Analytics
    config.segment_io_secret = ENV['SEGMENT_IO_SECRET']
    config.segment_io_error = Proc.new { |s,m| Rails.logger.info "[ANALYTICS] Error! Status: #{s}, Message: #{m}" }

    CarrierWave.configure do |config|
      config.cache_dir = Rails.root.join("tmp", "uploads")
      config.root      = Rails.root.join("tmp")

      config.fog_credentials = {
        :provider               => Rails.configuration.fog["provider"],
        :aws_access_key_id      => Rails.configuration.fog["aws_access_key_id"],
        :aws_secret_access_key  => Rails.configuration.fog["aws_secret_access_key"],
      }

      config.fog_directory  = Rails.configuration.fog['fog_directory']
      config.asset_host     = "http://#{Rails.configuration.fog['fog_directory']}"
      config.fog_public     = true
      config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    end

    # Mandrill // SMTP
    config.action_mailer.smtp_settings = {
      address: "smtp.mandrillapp.com",
      port: 587,
      enable_starttls_auto: true,
      user_name: "michael@belluba.com",
      password: ENV['MANDRILL_PASSWORD'],
      authentication: "login",
      domain: "dbld8.com"
    }

    config.action_mailer.default_url_options = { :host => "dbld8.com" }

    # For rspec
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    # config.default_share_message = ""
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/app/models/**/*", "#{config.root}/lib"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :user_observer, :activity_observer,
      :engagement_observer, :message_observer, :event_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Don't init entire rails env for asset compilation
    config.assets.initialize_on_precompile = false

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end