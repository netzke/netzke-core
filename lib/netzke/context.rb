require 'netzke/context/session'
require 'netzke/context/masquerading'

module Netzke
  module Context
    extend Session
    extend Masquerading
		mattr_accessor :controller
  end
end