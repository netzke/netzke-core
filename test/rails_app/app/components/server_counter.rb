class ServerCounter < Netzke::Base
  action :count_one_time # 1 request
  action :count_seven_times # 7 requests (should be batched)
  action :count_eight_times_special # passingm multiple arguments

  js_properties(
    :title => "Server Counter",
    :html => "Wow",
    :bbar => [:count_one_time.action, :count_seven_times.action, :count_eight_times_special.action]
  )  

  js_method :on_count_one_time, <<-JS
    function(){
      this.count({how_many: 1});
    }
  JS

  js_method :on_count_seven_times, <<-JS
    function(){
      for(var i=0;i<7;i++)
        this.count({how_many: 1});
    }
  JS

  js_method :on_count_eight_times_special, <<-JS
    function(){
      for(var i=0;i<8;i++)
        this.count({how_many: 1, special: true});
    }
  JS


  endpoint :count do |params|
    component_session[:count]||=0
    component_session[:count]+=params[:how_many]
    {:update => "I am at "+component_session[:count].to_s + (params[:special] ? ' and i was invoked specially' : '')}
  end

end