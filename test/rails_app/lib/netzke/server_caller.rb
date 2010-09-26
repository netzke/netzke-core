module Netzke
  class ServerCaller < Component::Base
    
    js_properties(
      :title => "Server Caller",
      :html => "Wow",
      :bbar => [{:text => "Call server", :ref => "../button"}],
    )
    
    js_method :bug_server, <<-JS
      function(){
        this.whatsUp();
        this.update('You should see the response from the server in the title bar the very next moment');
      }
    JS

    js_method :init_component, <<-JS
      function(){
        #{js_full_class_name}.superclass.initComponent.call(this);
        this.button.on('click', this.bugServer, this);
      }
    JS
    
    api :whats_up
    def whats_up(params)
      {:set_title => "All quiet here on the server"}
    end
    
  end
end