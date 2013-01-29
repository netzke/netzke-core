class LoadedRequireCss < Netzke::Base
  action :load do |c|
    c.text = "Load RequireCss"
  end

  component :require_css

  js_configure do |c|
    c.layout = :fit
    c.title = "LoadedRequireCss component"
    c.on_load = <<-JS
      function(){
        this.netzkeLoadComponent('require_css');
      }
    JS
  end

  def configure(c)
    super
    c.bbar = [:load]
  end
end
