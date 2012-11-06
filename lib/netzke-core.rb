$LOAD_PATH << File.dirname(__FILE__)

require 'netzke/core'
require 'netzke/base'

module Netzke
  autoload :Plugin, 'netzke/plugin'
  autoload :ActionConfig, 'netzke/action_config'
  autoload :ComponentConfig, 'netzke/component_config'
  autoload :EndpointResponse, 'netzke/endpoint_response'

  module Core
    autoload :Panel, 'netzke/core/panel'
  end
end

# Rails specific
if defined? Rails
  require 'netzke/railz'

  ActiveSupport.on_load(:action_controller) do
    include Netzke::Railz::ControllerExtensions
  end

  ActiveSupport.on_load(:action_view) do
    include Netzke::Railz::ActionViewExt
  end

  ActiveSupport.on_load(:after_initialize) do
    Netzke::Base.logger = Rails.logger
  end
else
  require 'logger'
  Netzke::Base.logger = Logger.new(STDOUT)
end
