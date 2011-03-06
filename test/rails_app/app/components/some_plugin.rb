class SomePlugin < Netzke::Base
  js_base_class "Ext.Component"

  endpoint :process_gear do |params|
    {:process_gear_callback => true}
  end

  js_method :init, <<-JS
    function(cmp){
      cmp.tools = [{id: 'gear', handler: this.onGear, scope: this}];
    }
  JS

  js_method :on_gear, <<-JS
    function(){
      this.processGear();
    }
  JS

  js_method :process_gear_callback, <<-JS
    function(){
      this.getParent().setTitle("Server response");
    }
  JS
end