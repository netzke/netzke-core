# Exends Endpoints test component by adding a button to desctroy the session, after which pressing any other button should result in the notification about expired session.
class SessionExpiration < Endpoints
  action :destroy_session

  def configure(c)
    super
    c.bbar << :destroy_session
  end

  endpoint :destroy_session do
    Netzke::Base.session.delete(:netzke_components)
  end
end
