# NOT USED?
class Feedback < Netzke::Base
  action :feedback
  action :server_feedback

  def configure(c)
    super
    c.bbar = [:feedback, :server_feedback]
  end

  client_class do |c|
    c.on_feedback = <<-JS
      function(){
        this.netzkeFeedback('Local feedback'); // uses global delay config
      }
    JS
    c.on_server_feedback = <<-JS
      function(){
        this.server.feedback();
      }
    JS
  end

  endpoint :feedback do |params,this|
    client.netzke_feedback("Server feedback", delay: 3000)
  end
end
