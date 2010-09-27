module Netzke
  module Deprecated
    class ServerCaller < Component::Base
      def config
        {
          :title => "Server caller",
          :bbar => [:call_server.ext_action]
        }.deep_merge super
      end
      
      js_method :on_call_server, <<-JS
        function(){
          this.whatsUp();
        }
      JS

      api :whats_up
      def whats_up(params)
        {:set_title => "Hello from the server!"}
      end
    end
  end
end