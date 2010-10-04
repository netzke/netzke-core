require 'active_support/core_ext'
require 'active_support/dependencies'

$LOAD_PATH << File.dirname(__FILE__)

require 'netzke/core_ext'

module Netzke
  autoload :Main, 'netzke/main'
  autoload :ExtComponent, 'netzke/ext_component'
  
  module Component
    autoload :Base,     'netzke/component/base'
    autoload :Actions,  'netzke/component/actions'
    autoload :Api,      'netzke/component/api'
  end
  
  class Engine < ::Rails::Engine
    config.before_configuration do
      # Include javascript & styles required by all Netzke components. 
      # These files will get loaded at the initial load of the framework (along with Ext).
      Netzke::Component::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/core.js"
      Netzke::Component::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/core.css"
    end
  end
end

# Rails specific
if defined? Rails
  require 'netzke/rails/routes'

  ActiveSupport.on_load(:action_controller) do
    require 'netzke/rails/controller_extensions'
    include Netzke::ControllerExtensions
  end

  ActiveSupport.on_load(:action_view) do
    require 'netzke/rails/action_view_ext'
    include Netzke::ActionViewExt
  end
  
  # Make this plugin auto-reloadable for easier development
  ActiveSupport::Dependencies.autoload_once_paths.delete(File.join(File.dirname(__FILE__)))
end
