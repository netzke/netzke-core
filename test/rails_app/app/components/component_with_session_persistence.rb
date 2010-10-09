class ComponentWithSessionPersistence < Netzke::Base
  js_properties :title => "No Title (yet!)", :bbar => [{:text => "Tell server to store new title", :ref => "../button"}]
  
  def default_config
    super.merge :session_persistence => true
  end
  
  js_method :bug_server, <<-JS
    function(){
      this.whatsUp();
      this.update('You should see the response from the server in the title bar the very next moment');
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
  end
  
end