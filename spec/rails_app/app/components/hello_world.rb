class HelloWorld < Netzke::Base
  # Configure clint class
  client_class do |c|
    c.title = "Hello World component"
  end

  # Actions are used by Ext JS to share functionality and state b/w buttons and menu items
  # The handler for this action should be called onPingServer by default
  action :ping_server

  # Self-configure with a bottom toolbar
  def configure(c)
    super
    c.bbar = [:ping_server] # embed the action into bottom toolbar
  end

  # Endpoint callable from client class
  endpoint :greet_the_world do
    # call client class' method showGreeting
    this.show_greeting("Hello World!")
  end
end
