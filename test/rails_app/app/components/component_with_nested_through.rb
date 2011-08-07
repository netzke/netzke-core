# Here the child component some_window gets declared with items being Netzke components in their turn
class ComponentWithNestedThrough < Netzke::Base
  js_property :layout, :fit
  js_property :border, true

  js_method :init_component, <<-JS
    function(){
      this.tools = [{type: 'gear', handler: this.onGear, scope: this}];
      this.callParent();
    }
  JS

  component :some_window, :class_name => "SimpleWindow", :width => 500, :layout => :fit, :modal => true,
            :items => [{
              :class_name => "SimpleTabPanel",
              :prevent_header => true,
              :items => [{:class_name => "ServerCaller"}, {:class_name => "ExtendedServerCaller"}]
            }]

  js_method :on_gear, <<-JS
    function(){
      this.loadNetzkeComponent({name: 'some_window', callback: function(w){
        w.show();
      }});
    }
  JS

end