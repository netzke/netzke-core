require 'active_support'

$LOAD_PATH << File.dirname(__FILE__)

require 'netzke/session'
require 'netzke/main'
require 'netzke/widget/aggregation'
require 'netzke/widget/base'
require 'netzke/action_view_ext'
require 'netzke/controller_extensions'
require 'netzke/core_ext'
require 'netzke/rails/routes'

# Load models and controllers from lib/app
%w{ models controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

ActiveSupport.on_load(:action_controller) do
  include Netzke::ControllerExtensions
end

ActiveSupport.on_load(:action_view) do
  include Netzke::ActionViewExt
end


# Make this plugin auto-reloadable for easier development
# ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))

# Include javascript & styles required by all Netzke widgets. 
# These files will get loaded at the initial load of the framework (along with Ext).
Netzke::Widget::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/core.js"
Netzke::Widget::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/core.css"

