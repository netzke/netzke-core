module Netzke
  class Plugin < Base
    client_class do |c|
      # We need to inherit from Ext.Component so that we recieve goodies like event handling
      c.extend = "Ext.Component"
    end
  end
end
