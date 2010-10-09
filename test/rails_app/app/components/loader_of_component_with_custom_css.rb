# Loads a component with custom CSS, to make sure that also dynamically loaded components get the correct CSS applied
class LoaderOfComponentWithCustomCss < Netzke::Base
  component :component_with_custom_css, :class_name => "ComponentWithCustomCss", :lazy_loading => true
  
  js_properties :title => "LoaderOfComponentWithCustomCss", :layout => 'fit', :bbar => [{:text => "Load ComponentWithCustomCss", :ref => "../button"}]
    
  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);
      this.button.on('click', function(){
        this.loadComponent({id: 'component_with_custom_css', container: this.getId()});
      }, this);
    }
  JS
end