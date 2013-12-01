class SimpleWindow < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.window.Window"
  end
end
