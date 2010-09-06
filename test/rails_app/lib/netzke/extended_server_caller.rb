module Netzke
  class ExtendedServerCaller < ServerCaller
    def self.js_properties
      {
        :title => "Extended Server Caller",
        :bug_server => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.body.update("I'm extended server caller");
            #{js_full_class_name}.superclass.bugServer.call(this);
          }
        END_OF_JAVASCRIPT
      }
    end
    
    def whats_up(params)
      {:set_title => super[:set_title] + ", shiny weather"}
    end
  end
end