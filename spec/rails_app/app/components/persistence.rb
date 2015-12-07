# Shows how component session and state can be used for persistence
class Persistence < Netzke::Base
  action :set_state
  action :reset_state

  action :set_session_variable
  action :retrieve_session_variable

  def configure(c)
    super
    c.bbar = [:set_state, :reset_state, :set_session_variable, :retrieve_session_variable]

    # title will be gotten from component's state
    c.title = state[:title] || "Default title"
  end

  client_class do |c|
    c.on_set_state = <<-JS
      function(){
        this.server.setState();
      }
    JS

    c.on_reset_state = <<-JS
      function(){
        this.server.resetState();
      }
    JS

    c.on_set_session_variable = <<-JS
      function(){
        this.server.setSessionVariable();
      }
    JS

    c.on_retrieve_session_variable = <<-JS
      function(){
        this.server.retrieveSessionVariable(null, function(result){
          this.setTitle("Session variable: " + result);
        })
      }
    JS
  end

  endpoint :set_state do
    state[:title] = "Title from state"
  end

  endpoint :reset_state do
    state.clear
  end

  endpoint :set_session_variable do
    component_session[:some_variable] = "set"
  end

  endpoint :retrieve_session_variable do
    this.nz_set_result(component_session[:some_variable] || "not set")
  end
end
