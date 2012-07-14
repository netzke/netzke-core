# This is an example of dividing component's code into modules. Use it to build complex components.
class KindaComplexComponent < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.TabPanel"
  end

  include BasicStuff
  include ExtraStuff
end
