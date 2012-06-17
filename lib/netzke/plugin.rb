module Netzke
  class Plugin < Base
    # js_base_class "Ext.Component"
    def self.js_config(c)
      c.extend = "Ext.Component"
    end

    def self.js_alias_prefix
      "plugin"
    end

    js_method :init, <<-JS
      function(cmp){
        this.cmp = cmp;
      }
    JS
  end
end
