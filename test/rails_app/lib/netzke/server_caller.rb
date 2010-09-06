module Netzke
  class ServerCaller < Widget::Base
    
    def self.js_properties
      {
        :title => "Server Caller",
        :html => "Wow",
        :bbar => [{:text => "Call server", :ref => "../button"}],
        :bug_server => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.whatsUp();
            this.update('You should see the response from the server in the title bar the very next moment');
          }
        END_OF_JAVASCRIPT

        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', this.bugServer, this);
          }
        END_OF_JAVASCRIPT
      }
    end
    
    api :whats_up
    def whats_up(params)
      {:set_title => "All quiet here on the server"}
    end
    
  end
end