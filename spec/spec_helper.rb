ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'database_cleaner'
require 'factory_girl_rails'

RSpec.configure do |config|
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  # Devise test helpers
  config.include Devise::TestHelpers, :type => :controller

  # Database Cleaner setup for integration specs
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each)  { DatabaseCleaner.clean }
end
