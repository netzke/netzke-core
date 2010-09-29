require 'netzke/session'

module Netzke
  class Main
    include Session

		cattr_accessor :controller
  end
end