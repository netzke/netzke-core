class HelloWorldComponent < Netzke::Base
  # Ext.Panel's config option "title"
  js_property :title, "My Hello World Component"

  # Bottom bar with an automatically created action
  js_property :bbar, [:bug_server.action]

  # Action to be placed on the bottom bar
  action :bug_server, :text => 'Greet the World', :icon => :accept

  # Method in the JS class that (by default) processes the action's "click" event
  js_method :on_bug_server, <<-JS
    function(){
      // Remotely calling the server's method greet_the_world (defined below)
      this.greetTheWorld();
    }
  JS

  # Server's method that gets called from the JS
  endpoint :greet_the_world do |params|
    # Tell the client side to call its method showGreeting with "Hello World!" as parameter
    {:show_greeting => "Hello World!"}
  end

  # Another method in the JS class that gets remotely called by the server side
  js_method :show_greeting, <<-JS
    function(greeting){
      this.body.update("Server says: " + greeting);
    }
  JS
end