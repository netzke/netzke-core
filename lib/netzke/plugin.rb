module Netzke
  class Plugin < Base
    js_configure do |c|
      c.extend = "Ext.Component"
      c.init = <<-JS
        function(cmp){
          this.cmp = cmp;
        }
      JS
    end

    def self.js_alias_prefix
      "plugin"
    end
  end
end
