module Touch
  class HelloWorldComponent < Netzke::Base
    js_base_class "Ext.Panel"

    def configuration
      super.merge({
        :docked_items => [{:dock => :top, :xtype => :toolbar, :title => 'Hello World Component',
          :items => [
            {:text => "Greet the World", :handler => :on_bug_server}
          ]
        }]
      })
    end

    js_method :on_bug_server, <<-JS
      function(){
        this.greetTheWorld();
      }
    JS

    endpoint :greet_the_world do |params|
      {:update => "Hello from the server!"}
    end
  end
end
