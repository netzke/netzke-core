require 'netzke/core'
require 'netzke/base'

module Netzke
  autoload :Plugin, 'netzke/plugin'

  module Core
    autoload :ComponentConfig, 'netzke/core/component_config'
    autoload :ActionConfig, 'netzke/core/action_config'
    autoload :Panel, 'netzke/core/panel'
    autoload :EndpointResponse, 'netzke/core/endpoint_response'
  end
end

# Rails specific
if defined? Rails
  require 'netzke/core/railz'

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
