# Set the default environment to sqlite3's in_memory database
ENV['RAILS_ENV'] ||= 'in_memory'

# Load the Rails environment and testing framework
require "#{File.dirname(__FILE__)}/app_root/config/environment"
require 'test_help'

# Undo changes to RAILS_ENV
silence_warnings {RAILS_ENV = ENV['RAILS_ENV']}

# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# Set default fixture loading properties
ActiveSupport::TestCase.class_eval do
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
  self.fixture_path = "#{File.dirname(__FILE__)}/fixtures"
  
  fixtures :all
end
