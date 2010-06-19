require 'active_support'

# NetzkeCore
require 'netzke/base'

require 'netzke/action_view_ext'
require 'netzke/controller_extensions'
require 'netzke/core_ext'
# require 'netzke/routing'
require 'netzke/rails/routes'

# Load models and controllers from lib/app
%w{ models controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

if defined? ActionController
  ActionController::Base.class_eval do
    include Netzke::ControllerExtensions
  end

  # Include the route to the Netzke controller
  # ActionController::Routing::RouteSet::Mapper.send :include, Netzke::Routing::MapperExtensions
end

if defined? ActionView
  ActionView::Base.send :include, Netzke::ActionViewExt
end  

# Make this plugin auto-reloadable for easier development
ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))

# Include javascript & styles required by all Netzke widgets. 
# These files will get loaded at the initial load of the framework (along with Ext).
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/core.js"
Netzke::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/core.css"
