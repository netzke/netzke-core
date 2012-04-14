class ComponentWithSessionPersistence < Netzke::Base
  title "Default Title"

  js_property :bbar, [:bug_server]

  action :bug_server do |a|
    a.text = "Tell server to store new title"
  end

  def configure
    config.session_persistence = true
    super
    config.html = component_session[:html_content] || "Default HTML"
  end

  js_method :bug_server, <<-JS
    function(){
      this.whatsUp();
    }
  JS

  js_method :on_bug_server, <<-JS
    function(){
      this.bugServer();
    }
  JS

  endpoint :whats_up do |params|
    update_session_options(:title => "Title From Session") # setting a value in session_options, which will get auto-merged into +config+
    component_session[:html_content] = "HTML from session" # setting some custom session key/value, which we use manually in +configuration+
    {}
  end

end
