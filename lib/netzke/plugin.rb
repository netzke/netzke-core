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
  end
end
