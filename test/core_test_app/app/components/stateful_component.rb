# Shows how component session and state can be used for persistence
class StatefulComponent < Netzke::Base
  action :set_session_data do |a|
    a.text = "Set session and state"
  end

  action :reset_session_data do |a|
    a.text = "Reset session and state"
  end

  def configure(c)
    super
    c.persistence = true
    c.bbar = [:set_session_data, :reset_session_data]

    # title will be gotten from component's state
    c.title = state[:title] || "Default Title"

    # body content will be stored directly in component's session
    c.html = component_session[:html_content] || "Default HTML"
  end

  js_configure do |c|
    c.on_set_session_data = <<-JS
      function(){
        this.serverSetSessionData();
      }
    JS

    c.on_reset_session_data = <<-JS
      function(){
        this.serverResetSessionData();
      }
    JS
  end

  endpoint :server_set_session_data do |params, this|
    component_session[:html_content] = "HTML from session"
    state[:title] = "Title From State"
  end

  endpoint :server_reset_session_data do |params,this|
    component_session.clear
    state.clear
  end
end
