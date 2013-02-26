require 'active_support/core_ext'

module Netzke
  # This module implements high-level configuration for Netzke Core.
  #
  # You can configure Netzke::Core like this:
  #
  #     Netzke::Core.setup do |config|
  #       config.ext_location = "/home/netzke/ext-4.1.1"
  #       config.icons_uri = "/images/famfamfam/icons"
  #       # ...
  #     end
  #
  # The following configuration options are available:
  # * ext_path - absolute path to your Ext code root
  # * icons_uri - relative URI to the icons
  module Core
    autoload :ComponentConfig, 'netzke/core/component_config'
    autoload :ActionConfig, 'netzke/core/action_config'
    autoload :Panel, 'netzke/core/panel'
    autoload :EndpointResponse, 'netzke/core/endpoint_response'
    autoload :Version, 'netzke/core/version'
    autoload :DynamicAssets, 'netzke/core/dynamic_assets'
    autoload :ClientClass, 'netzke/core/client_class'
    autoload :CssConfig, 'netzke/core/css_config'
    autoload :ConfigToDslDelegator, 'netzke/core/config_to_dsl_delegator'

    # :ext (or :touch - when and if ever implemented)
    mattr_accessor :platform
    @@platform = :ext

    mattr_accessor :ext_javascripts
    @@ext_javascripts = []

    mattr_accessor :ext_stylesheets
    @@ext_stylesheets = []

    # Stylesheets that cannot be loaded dynamically along with the rest of the component, e.g. due to that relative paths are used in them
    mattr_accessor :external_ext_css
    @@external_ext_css = []

    mattr_accessor :icons_uri
    @@icons_uri = "/images/icons"

    mattr_accessor :ext_uri
    @@ext_uri = "/extjs"

    mattr_accessor :ext_path

    # The amount of retries that the direct remoting provider will attempt in case of failure
    mattr_accessor :js_direct_max_retries
    @@js_direct_max_retries = 0

    mattr_accessor :with_icons
    
    mattr_accessor :parent_controller_class

    def self.setup
      yield self
    end

    def self.reset_components_in_session
      Netzke::Base.session[:netzke_components].try(:clear)
    end
  end
end
