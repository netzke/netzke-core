class SelfReloading < Netzke::Base
  action :reload

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

  client_class do |c|
    c.on_reload = <<-JS
      function(){
        this.netzkeReload();
      }
    JS
  end
end
