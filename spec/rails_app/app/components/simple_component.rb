class SimpleComponent < Netzke::Base
  action :hello

  def configure(c)
    c.bbar = [:hello]
    c.title = c.client_config[:title] || "SimpleComponent"
    super
  end

  endpoint :hello do
    "hi!"
  end

  client_class do |c|
    c.netzke_on_hello = l(<<-JS)
      function() {
        this.server.hello(function(response) { this.setTitle("Server says: " + response); });
      }
    JS
  end
end
