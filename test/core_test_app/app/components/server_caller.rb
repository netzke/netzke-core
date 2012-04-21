class ServerCaller < Netzke::Base
  title "Server Caller!"

  action :bug_server # Actual action's text is set in en.yml

  js_properties(
    :title => "Server Caller",
    :html => "Wow"
  )

  def configure
    super
    config.tbar = [:bug_server]
  end

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
