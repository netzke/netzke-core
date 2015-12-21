class ClientConfig < Netzke::Base
  def configure(c)
    super
    c.layout = :hbox
    c.defaults = { height: "100%" }
    c.some_option = client_config.some_option
    c.bbar = [:show_option_one, :show_option_two]

    child_config = { klass: HelloUser, flex: 1 }
    c.items = [child_config.merge(item_id: 'left'), child_config.merge(item_id: 'right')]
  end

  endpoint :request_some_option do
    config.some_option
  end

  action :show_option_one do |c|
    c.handler = :handle_show_option
    c.option = 'One'
  end

  action :show_option_two do |c|
    c.handler = :handle_show_option
    c.option = 'Two'
  end
end
