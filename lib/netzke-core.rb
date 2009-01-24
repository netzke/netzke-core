# NetzkeCore
require 'netzke/js_class_builder'
require 'netzke/base'
require 'netzke/feedback_ghost'
require 'netzke/action_view_ext'
require 'netzke/controller_extensions'
require 'netzke/core_ext'
require 'netzke/routing'

# Vendor
require 'vendor/facets/hash/recursive_merge'

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
  ActionController::Routing::RouteSet::Mapper.send :include, Netzke::Routing::MapperExtensions
end

if defined? ActionView
  ActionView::Base.send :include, Netzke::ActionViewExt
end  

# Make this plugin auto-reloadable for easier development
ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))

# Include javascript & styles
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/core.js"
Netzke::Base.config[:css] << "#{File.dirname(__FILE__)}/../css/core.css"
