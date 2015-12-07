class LoadedCssInclusion < Netzke::Base
  action :load do |c|
    c.text = "Load CssInclusion"
  end

  component :css_inclusion

  client_class do |c|
    c.layout = :fit
    c.title = "LoadedCssInclusion component"
    c.on_load = <<-JS
      function(){
        this.nzLoadComponent('css_inclusion');
      }
    JS
  end

  def configure(c)
    super
    c.bbar = [:load]
  end
end
