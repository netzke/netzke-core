class ServerCaller < Netzke::Base
  action :bug_server # Actual action's text is set in en.yml

  js_properties(
    :title => "Server Caller",
    :html => "Wow",
    :tbar => [:bug_server.action] # TODO: used to be bbar, but Ext 4.0.2 has problems with rendering it!
  )

  js_method :on_bug_server, <<-JS
    function(){
      this.whatsUp();
      this.update('You should see the response from the server in the title bar the very next moment');
    }
  JS

  endpoint :whats_up do |params|
    {:set_title => "All quiet here on the server"}
  end

end