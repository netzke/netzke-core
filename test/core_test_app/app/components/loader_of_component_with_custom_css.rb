# Loads a component with custom CSS, to make sure that also dynamically loaded components get the correct CSS applied
class LoaderOfComponentWithCustomCss < Netzke::Base
  component :component_with_custom_css do |c|
    c.klass = ComponentWithCustomCss
  end

  action :load_component_with_custom_css

  def configure(c)
    super
    c.title = "LoaderOfComponentWithCustomCss"
    c.layout = :fit
    c.bbar = [:load_component_with_custom_css]
  end

  js_configure do |c|
    c.on_load_component_with_custom_css = <<-JS
    function(params){
      this.netzkeLoadComponent({name: 'component_with_custom_css', container: this});
    }
    JS
  end
end
