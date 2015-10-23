# Exends Endpoints test component by adding a button to desctroy the session, after which pressing any other button should result in the notification about expired session.
class SessionExpiration < Endpoints
  action :destroy_session

  client_class do |c|
    c.on_destroy_session = <<-JS
      function(){
        this.serverDestroySession();
      }
    JS
  end

  def configure(c)
    super
    c.bbar << :destroy_session
  end

  endpoint :server_destroy_session do
    Netzke::Base.session.delete(:netzke_components)
  end
end
