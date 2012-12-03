Sims::Application.configure do
# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.consider_all_requests_local = false
config.action_controller.perform_caching             = true


config.log_level = :debug
config.active_support.deprecation = :log

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
 config.action_mailer.raise_delivery_errors = false
 config.action_mailer.delivery_method = :test



  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

#ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => '.sims-open.vegantech.com')

# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
end
require 'mail'
Mail.register_observer(Railmail::Observer)
