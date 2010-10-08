module Deprecated
  class ServerCaller < Netzke::Base
    def config
      {
        :title => "Server caller",
        :bbar => [:call_server.action]
      }.deep_merge super
    end
    
    js_method :on_call_server, <<-JS
      function(){
        this.whatsUp();
      }
    JS

    endpoint :whats_up |params|
      {:set_title => "Hello from the server!"}
    end
  end
end
