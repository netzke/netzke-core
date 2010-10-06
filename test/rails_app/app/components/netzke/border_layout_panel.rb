module Netzke
  # It's a primitive BorderLayoutPanel, but don't let it fool you - it's a fully functionaly Netzke component: it handles components, can be dynamically loaded, nested, etc.
  class BorderLayoutPanel < Base
    def self.js_properties
      {
        :layout => 'border'
      }
    end
  end
end