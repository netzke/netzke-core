require 'active_support/core_ext'
require 'netzke/core/options_hash'
require 'netzke/core/version'
require 'netzke/core/session'
require 'netzke/core/masquerading'
require 'netzke/core/dynamic_assets'
require 'netzke/core/client_class'
require 'netzke/core/css_config'
require 'netzke/config_to_dsl_delegator'

module Netzke
  # This module implements high-level configuration for Netzke Core.
  #
  # You can configure Netzke::Core like this:
  #
  #     Netzke::Core.setup do |config|
  #       config.ext_location = "/home/netzke/ext-3.3.0"
  #       config.icons_uri = "/images/famfamfam/icons"
  #       # ...
  #     end
  #
  # The following configuration options are available:
  # * ext_location - absolute path to your Ext code root
  # * icons_uri - relative URI to the icons
  module Core
    extend Session
    extend Masquerading

    # Later is set to Rails.logger if using Rails, or to Logger from stdlib otherwise
    mattr_accessor :logger

    # :ext (or :touch - when and if ever implemented)
    mattr_accessor :platform
    @@platform = :ext

    # set in Netzke::ControllerExtensions
    mattr_accessor :controller

    # set in Netzke::ControllerExtensions
    mattr_accessor :session
    @@session = {}

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

    mattr_accessor :current_user_method
    @@current_user_method = :current_user

    mattr_accessor :persistence_manager
    @@persistence_manager = "NetzkeComponentState"

    # The amount of retries that the direct remoting provider will attempt in case of failure
    mattr_accessor :js_direct_max_retries
    @@js_direct_max_retries = 0

    mattr_accessor :with_icons

    mattr_accessor :persistence_manager_class

    def self.setup
      yield self
    end

    def self.reset_components_in_session
      Netzke::Core.session[:netzke_components].try(:clear)
    end

    # returns a full URI to an icon file by its name
    def self.uri_to_icon(icon)
      with_icons ? [(controller && controller.config.relative_url_root), icons_uri, '/', icon.to_s, ".png"].join : nil
    end
  end
end
