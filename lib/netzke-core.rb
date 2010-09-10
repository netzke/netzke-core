require 'active_support/core_ext'
require 'active_support/dependencies'

$LOAD_PATH << File.dirname(__FILE__)

require 'netzke/core_ext'

module Netzke
  autoload :Main, 'netzke/main'
  
  module Widget
    autoload :Base,     'netzke/widget/base'
    autoload :Actions,  'netzke/widget/actions'
    autoload :Api,      'netzke/widget/api'
    
    # What's below will go to a separate gem
    # autoload :Panel, 'netzke/widget/panel'
  end
end

# Rails specific
if defined? Rails
  require 'active_support'
  require 'netzke/rails/routes'

  # Load models and controllers from lib/app
  %w{ models controllers }.each do |dir|
    path = File.join(File.dirname(__FILE__), 'app', dir)
    $LOAD_PATH << path
    ActiveSupport::Dependencies.autoload_paths << path
    ActiveSupport::Dependencies.autoload_once_paths.delete(path)
  end

  require 'netzke/rails/controller_extensions'
  ActiveSupport.on_load(:action_controller) do
    include Netzke::ControllerExtensions
  end

  require 'netzke/rails/action_view_ext'
  ActiveSupport.on_load(:action_view) do
    include Netzke::ActionViewExt
  end
  
  # Make this plugin auto-reloadable for easier development
  ActiveSupport::Dependencies.autoload_once_paths.delete(File.join(File.dirname(__FILE__)))
end

# Include javascript & styles required by all Netzke widgets. 
# These files will get loaded at the initial load of the framework (along with Ext).
Netzke::Widget::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/core.js"
Netzke::Widget::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/core.css"

