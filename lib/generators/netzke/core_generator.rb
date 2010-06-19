require 'rails/generators'
require 'rails/generators/migration'
require 'generators/migration_helper'

module Netzke
  module Generators  
    class CoreGenerator < Rails::Generators::Base
      include ::MigrationHelper
      
      def execute
        migration_template 'create_netzke_preferences.rb', 'db/migrate/create_netzke_preferences.rb'
      end
      
      def self.source_root
        File.join(gem_root, 'templates', 'core')
      end        
      
      def self.gem_root
        File.expand_path("../../../../", __FILE__)
      end 
                 
    end
  end
end
