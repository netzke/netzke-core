# NetzkeCore
require 'netzke/js_class_builder'
require 'netzke/base'
require 'netzke/core_ext'
require 'netzke/controller_extensions'
# require 'netzke/with_properties'


%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActionController::Base.class_eval do
  include Netzke::ControllerExtensions
end
