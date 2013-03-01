class HamlPanel < Netzke::Base
  action :ping_server

  def js_configure(c)
    super

    c.title = "Haml panel"
    c.body_padding = 5

    @who = 'World'
    c.html = render(:body)

    c.bbar = [:ping_server]
  end

  js_configure do |c|
    c.on_ping_server = <<-JS
      function(){
        this.whatsUp();
      }
    JS

    c.update_body = <<-JS
      function(html){ this.update(html);}
    JS
  end

  endpoint :whats_up do |params,this|
    @time = Time.now
    this.update_body(render(:server_response))
  end
end
