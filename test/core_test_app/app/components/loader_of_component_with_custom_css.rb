# Loads a component with custom CSS, to make sure that also dynamically loaded components get the correct CSS applied
class LoaderOfComponentWithCustomCss < Netzke::Base
  component :component_with_custom_css do |c|
    c.klass = ComponentWithCustomCss
  end

  action :load_component_with_custom_css

  def configure
    super
    config.title = "LoaderOfComponentWithCustomCss"
    config.layout = :fit
    config.bbar = [:load_component_with_custom_css]
  end

  js_method :on_load_component_with_custom_css, <<-JS
    function(params){
      this.loadComponent({name: 'component_with_custom_css'});
    }
  JS
end
