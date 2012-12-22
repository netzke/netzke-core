class SelfReloading < Netzke::Base
  action :reload

  def configure(c)
    super
    c.bbar = [:reload]
  end

  def js_configure(c)
    super
    state[:loaded_times] ||= 0
    state[:loaded_times] += 1

    c.title = "Loaded #{state[:loaded_times]} time(s)"
  end

  js_configure do |c|
    c.on_reload = <<-JS
      function(){
        this.netzkeReload();
      }
    JS
  end
end
