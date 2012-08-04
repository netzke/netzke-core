module Netzke
  class Plugin < Base
    # js_base_class "Ext.Component"

    js_configure do |c|
      c.extend = "Ext.Component"
      c.init = <<-JS
        function(cmp){
          this.cmp = cmp;
        }
      JS
    end

    # def self.js_config(c)
    #   c.extend = "Ext.Component"
    # end

    def self.js_alias_prefix
      "plugin"
    end
  end
end
