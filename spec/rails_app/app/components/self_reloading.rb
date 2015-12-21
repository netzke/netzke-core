class SelfReloading < Netzke::Base
  action :reload do |c|
    c.handler = :netzke_reload
  end

  def configure(c)
    super
    c.bbar = [:reload]
  end

  def configure_client(c)
    super
    state[:loaded_times] ||= 0
    state[:loaded_times] += 1

    c.title ||= "Loaded #{state[:loaded_times]} time(s)"
  end
end
