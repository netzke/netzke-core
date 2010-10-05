# require 'active_support/core_ext'
# require 'active_support/dependencies'

# $LOAD_PATH << File.dirname(__FILE__)

# require 'netzke/core_ext'

require 'netzke/component/base'

module Netzke
  autoload :Main, 'netzke/main'
  autoload :ExtComponent, 'netzke/ext_component'
  
  class Engine < ::Rails::Engine
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
  # ActiveSupport::Dependencies.autoload_once_paths.delete(File.join(File.dirname(__FILE__)))
end
