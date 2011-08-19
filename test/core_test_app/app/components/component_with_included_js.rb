class ComponentWithIncludedJs < Netzke::Base
  js_include "#{File.dirname(__FILE__)}/included.js"

  js_base_class "Netzke.ComponentWithIncludedJs"

  action :print_message

  js_property :bbar, [:print_message.action]

  js_method :on_print_message, <<-JS
    function(){
      this.updateBodyWithMessage("Some message " + "shown in the body");
    }
  JS

end