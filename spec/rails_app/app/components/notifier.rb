class Notifier < Netzke::Base
  action :notify
  action :multiple_notify
  action :server_notify

  def configure(c)
    super
    c.bbar = [:notify, :multiple_notify, :server_notify]
  end

  endpoint :notify do
    client.netzke_notify("Message from server", delay: 3000, title: 'Server notification')
  end
end
