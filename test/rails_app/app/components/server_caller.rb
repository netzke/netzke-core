class ServerCaller < Netzke::Base
  action :bug_server, :text => "Call server"
  
  js_properties(
    :title => "Server Caller",
    :html => "Wow",
    :bbar => [:bug_server.action]
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