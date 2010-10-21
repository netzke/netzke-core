class ComponentWithSessionPersistence < Netzke::Base
  js_property :title, "No Title (yet!)"
  js_property :bbar, [{:text => "Tell server to store new title", :ref => "../button"}]
  
  config :default, :session_persistence => true

  js_method :bug_server, <<-JS
    function(){
      this.whatsUp();
    }
  JS

  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);
      this.button.on('click', this.bugServer, this);
    }
  JS
  
  endpoint :whats_up do |params|
    update_session_options(:title => "New Title!")
    {}
  end
  
end