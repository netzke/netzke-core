class ClientConfig < Netzke::Base
  def configure(c)
    super
    c.some_option = client_config.some_option
    c.bbar = [:show_option_one, :show_option_two]
  end

  endpoint :server_request_some_option do
    config.some_option
  end

  action :show_option_one do |c|
    c.handler = :on_show_option
    c.option = 'One'
  end

  action :show_option_two do |c|
    c.handler = :on_show_option
    c.option = 'Two'
  end

  js_configure do |c|
    c.on_show_option = <<-JS
      function(action) {
        this.netzkeClientConfig.some_option = action.option;
        this.serverRequestSomeOption(null, function(res){this.setTitle(res);});
      }
    JS
  end
end
