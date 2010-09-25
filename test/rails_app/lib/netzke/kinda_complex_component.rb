module Netzke
  # This is an example of dividing component's code into modules. Use it to build complex components.
  class KindaComplexComponent < Component::Base
    js_base_class "Ext.TabPanel"

    include BasicStuff
    include ExtraStuff
  end
end