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
    
    def self.setup
      yield self
    end
  end
end