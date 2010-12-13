$LOAD_PATH << File.dirname(__FILE__)

require 'netzke/core'
require 'netzke/base'

module Netzke
  autoload :Core, 'netzke/core'
  autoload :ExtComponent, 'netzke/ext_component'

  module Core
    class Engine < ::Rails::Engine
      config.after_initialize do
        # Do some initialization which only is possible after Rails is initialized
        Netzke::Core.ext_location ||= ::Rails.root.join("public", "extjs")
        Netzke::Core.touch_location ||= ::Rails.root.join("public", "sencha-touch")
        Netzke::Core.with_icons = File.exists?("#{::Rails.root}/public#{Netzke::Core.icons_uri}") if Netzke::Core.with_icons.nil?
        Netzke::Core.persistence_manager_class = Netzke::Core.persistence_manager.constantize rescue nil
      end
    end
  end
end

# Rails specific
if defined? Rails
  require 'netzke/rails'

  ActiveSupport.on_load(:action_controller) do
    include Netzke::Rails::ControllerExtensions
  end

  ActiveSupport.on_load(:action_view) do
    include Netzke::Rails::ActionViewExt
  end
end
