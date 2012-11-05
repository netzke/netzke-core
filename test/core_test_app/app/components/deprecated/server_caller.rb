module Deprecated
  class ServerCaller < Netzke::Base
    js_properties :title => "Server caller",
                  :bbar => [:call_server]

    js_method :on_call_server, <<-JS
      function(){
        this.whatsUp();
      }
    JS

    ActiveSupport::Deprecation.silence do
      api :whats_up
    end

    def whats_up(params)
      {:set_title => "Hello from the server!"}
    end
  end
end
