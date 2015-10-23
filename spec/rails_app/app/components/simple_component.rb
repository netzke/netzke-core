class SimpleComponent < Netzke::Base
  action :hello

  def configure(c)
    c.bbar = [:hello]
    c.title = c.client_config[:title] || "SimpleComponent"
    super
  end

  endpoint :server_hello do
    "hi!"
  end

  client_class do |c|
    c.on_hello = <<-JS
      function() {
        this.serverHello(function(response) { this.setTitle("Server says: " + response); });
      }
    JS
  end
end
