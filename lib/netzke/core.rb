require 'active_support/core_ext'
require 'netzke/core/version'
require 'netzke/core/session'
require 'netzke/core/masquerading'

module Netzke
  module Core
    extend Session
    extend Masquerading
    
    mattr_accessor :controller

    mattr_accessor :javascripts
    @@javascripts = ["#{File.dirname(__FILE__)}/../../javascripts/core.js"]

    mattr_accessor :stylesheets
    @@stylesheets = ["#{File.dirname(__FILE__)}/../../stylesheets/core.css"]
    
    mattr_accessor :external_css
    @@external_css = []

    mattr_accessor :ext_location
    
    mattr_accessor :with_icons
    
    mattr_accessor :icons_uri
    @@icons_uri = "/images/icons"
    
    def self.setup
      yield self
    end
  end
end