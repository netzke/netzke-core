module Netzke
  class Plugin < Base
    client_class do |c|
      c.extend = "Ext.Component"
      c.init = <<-JS
        function(cmp){
          this.cmp = cmp;
        }
      JS
    end
  end
end
