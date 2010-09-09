# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
 
  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/ttv #{RAILS_ROOT}/app/ballots)

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  config.gem "authlogic"
  config.gem "prawn", :version => '>= 0.7.2'
  config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
  config.gem 'tpitale-constant_cache', :lib => 'constant_cache', :version => '>= 0.1.2'
  config.gem 'rubyzip', :version => '>= 0.9.4', :lib => 'zip/zip'
  config.gem 'searchlogic', :version => '>=2.4.14'
  config.gem 'cancan'
  config.gem 'faker'
  config.gem 'machinist'
  config.gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"
  config.gem 'pdf-reader'
  
  
  unless !ENV['TM_DIRECTORY'].nil?
    config.gem 'redgreen', :version => '>=1.2.2'
  end
  
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Pacific Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  # session in a cookie config
  config.action_controller.session = { 
    :key => 'TrustTheVote', 
    :secret      => '22acc6b566d2328b8d775d1ea25daef6814918c2216c90d292c09e7db2d76bba4285c44607f7d051a1255e1757a9639660d595130c0a05a72ceb23c60c9c5750' 
  }
end

Paperclip.options[:command_path] = "/usr/local/bin"
