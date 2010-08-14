module Netzke
  class ServerCaller < Widget::Base
    
    def self.js_extend_properties
      {
        :title => "Server Caller",
        :buttons => [{:text => "Call server", :ref => "../button"}],
        :ask_server => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.whatIsTheTime();
          }
        END_OF_JAVASCRIPT
        
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', this.askServer, this);
          }
        END_OF_JAVASCRIPT
      }
    end
    
    api :what_is_the_time
    def what_is_the_time(params)
      {:set_title => "13:62pm"}
    end
    
  end
end