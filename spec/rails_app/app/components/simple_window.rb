class SimpleWindow < Netzke::Base
  client_class do |c|
    c.extend = "Ext.window.Window"
  end
end
