require 'active_support/core_ext'
require 'netzke/core/version'
require 'netzke/core/session'
require 'netzke/core/masquerading'

module Netzke
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
  # * javascript_on_main_page (true/false, defaults to false) - if you want the JS classes to be inserted into the code of the page,
  # rather than into netzke.js (setting to true can be handy for debugging)
  module Core
    extend Session
    extend Masquerading

    # set in Netzke::ControllerExtensions
    mattr_accessor :controller
    
    # set in Netzke::ControllerExtensions
    mattr_accessor :session
    @@session = {}

    mattr_accessor :javascripts
    @@javascripts = ["#{File.dirname(__FILE__)}/../../javascripts/core.js"]

    mattr_accessor :stylesheets
    @@stylesheets = ["#{File.dirname(__FILE__)}/../../stylesheets/core.css"]

    mattr_accessor :external_css
    @@external_css = []

    # Set in the Engine after_initialize callback
    mattr_accessor :ext_location
    mattr_accessor :with_icons

    mattr_accessor :icons_uri
    @@icons_uri = "/images/icons"

    mattr_accessor :javascript_on_main_page
    @@javascript_on_main_page = true

    mattr_accessor :persistence_manager
    @@persistence_manager = "NetzkeComponentState"
    
    # Set in the Engine after_initialize callback
    mattr_accessor :persistence_manager_class

    def self.setup
      yield self
    end

    def self.reset_components_in_session
      Netzke::Core.session[:netzke_components].try(:clear)
    end
  end
end