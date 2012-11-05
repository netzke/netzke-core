class HelloWorldComponent < Netzke::Base
  def configure(c)
    c.bbar = [:ping_server]
    super
  end

  action :ping_server

  endpoint :greet_the_world do |params,this|
    this.show_greeting "Hello World!"
  end

  js_configure do |c|
    c.on_ping_server = <<-JS
      function(){
        // Remotely calling the server's method greet_the_world (defined below)
        this.greetTheWorld();
      }
    JS

    c.show_greeting = <<-JS
      function(greeting){
        this.body.update("Server says: " + greeting);
      }
    JS
  end
end
