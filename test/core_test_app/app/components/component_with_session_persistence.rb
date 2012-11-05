class ComponentWithSessionPersistence < Netzke::Base
  action :bug_server do |a|
    a.text = "Tell server to store new title"
  end

  def configure(c)
    c.session_persistence = true
    c.title = "Default Title"
    super
    c.html = component_session[:html_content] || "Default HTML"
    c.bbar = [:bug_server]
  end

  js_configure do |c|
    c.bug_server = <<-JS
      function(){
        this.whatsUp();
      }
    JS

    c.on_bug_server = <<-JS
      function(){
        this.bugServer();
      }
    JS
  end

  endpoint :whats_up do |params, this|
    update_session_options(:title => "Title From Session") # setting a value in session_options, which will get auto-merged into +config+
    component_session[:html_content] = "HTML from session" # setting some custom session key/value, which we use manually in +configuration+
  end
end
