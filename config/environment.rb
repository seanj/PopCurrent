# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'



# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.1.6'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :mem_cache_store
  
  #config.action_controller.session_store = :sql_session_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.
#       update(:database_manager => SqlSessionStore)
#SqlSessionStore.session_class = MysqlSession

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

module LoginEngine
  config :salt, "shahya-rersaj-beejwo-eywysapa-ruickarl"
  config :use_email_notification, true
  config :app_name, 'PopCurrent'
  config :app_url, 'http://popcurrent.com'
  config :email_from, 'contact@popcurrent.com'
  config :admin_email, 'contact@popcurrent.com'
  config :security_token_life_hours, 168
end

module UserEngine
  config :admin_login, "foo"
  config :admin_email, "foo@bar.com"
  config :admin_password, "bar"
  config :user_role_table, "_roles"
end

Engines.start
UserEngine.check_system_roles
ActiveRecord::Base.verification_timeout = 14400
ExceptionNotifier.exception_recipients = %w(foo@bar.com)
