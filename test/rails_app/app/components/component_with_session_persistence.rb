class ComponentWithSessionPersistence < Netzke::Base
  js_property :title, "Default Title"
  js_property :bbar, [{:text => "Tell server to store new title", :ref => "../button"}]

  def default_config
    super.merge(:session_persistence => true)
  end

  def configuration
    super.merge(:html => component_session[:html_content] || "Default HTML")
  end

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
    update_session_options(:title => "Title From Session") # setting a value in session_options, which will get auto-merged into +config+
    component_session[:html_content] = "HTML from session" # setting some custom session key/value, which we use manually in +configuration+
    {}
  end

end