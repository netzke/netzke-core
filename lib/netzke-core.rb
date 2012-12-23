# Hobo specific
#
# Hobo includes a bunch of extensions and patches to various Rails and Ruby
# classes including ActiveRecord, Array and Hash in it's `hobo_support` gem.
#
# To let both libraries co-exist nicely let's make sure that the Hobo
# extensions and patches to Rails and Ruby classes get loaded before
# requiring Netzke's extensions and patches.
#
# Important: To make this work Hobo must be listed before the Netzke gems
#            in the Gemfile!
#
# This has been tested with Hobo 2.0.0.pre7 and Rails 3.2.9.
#
if defined? HoboSupport
  require 'hobo_support'
end

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
