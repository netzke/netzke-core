class ServerCounter < Netzke::Base
  action :count_one_time # 1 request
  action :count_seven_times # 7 requests (should be batched)
  action :count_eight_times_special # passingm multiple arguments
  action :fail_in_the_middle # calls 3 endpoints of which the second fails
  action :do_ordered # used for test if call order is preserved
  action :count_appending

  js_properties(
    :title => "Server Counter",
    :bbar => [:count_one_time.action, :count_seven_times.action, :count_eight_times_special.action, :fail_in_the_middle.action, :do_ordered.action, :count_appending.action]
  )

  js_method :on_count_one_time, <<-JS
    function(){
      this.count({how_many: 1});
    }
  JS

  js_method :init_component, <<-JS
    function () {
      #{js_full_class_name}.superclass.initComponent.call(this);
      Ext.Ajax.on('beforerequest',function (conn, options ) {
        Netzke.connectionCount = Netzke.connectionCount || 0;
        Netzke.connectionCount++;
        Netzke.lastOptions=options;
      });

    }
  JS

  js_method :on_count_seven_times, <<-JS
    function(){
      for(var i=0; i<7; i++)
        this.count({how_many: 1});
    }
  JS

  js_method :on_count_eight_times_special, <<-JS
    function(){
      for(var i=0;i<8;i++)
        this.count({how_many: 1, special: true});
    }
  JS

  js_method :on_fail_in_the_middle, <<-JS
    function() {
      this.successingEndpoint();
      this.failingEndpoint();
      this.successingEndpoint();
    }
  JS

  js_method :on_do_ordered, <<-JS
    function () {
      this.firstEp();
      this.secondEp();
    }
  JS

  js_method :update_appending, <<-JS
    function(html){
      if (!this.panelText) { this.panelText = ""; }
      this.panelText += html + ",";
      this.body.update(this.panelText);
    }
  JS

  js_method :on_count_appending, <<-JS
    function(){
      for(var i=0; i<5; i++) {
        this.countAppending();
      }
    }
  JS

  def before_load
    component_session[:count] = 0
  end

  endpoint :count do |params|
    component_session[:count]||=0
    component_session[:count]+=params[:how_many]
    {:update => "I am at "+component_session[:count].to_s + (params[:special] ? ' and i was invoked specially' : '')}
  end

  endpoint :successing_endpoint do |params|
    {:update  => "Something successed "}
  end

  endpoint :failing_endpoint do |params|
    throw "something happened"
    {:update => "This will never get returned"}
  end

  endpoint :first_ep do |params|
    component_session[:count]||=0
    component_session[:count]+=1
    {:update => "First. "+ component_session[:count].to_s}
  end

  endpoint :second_ep do |params|
    component_session[:count]||=0
    component_session[:count]+=1
    {:update => "Second. "+ component_session[:count].to_s}
  end

  endpoint :count_appending do |params|
    component_session[:count] ||= 0
    component_session[:count] += 1

    # On the 3rd request fail, but don't fail at a retry
    if (component_session[:count] == 3 && !component_session[:is_retry])
      component_session[:is_retry] = true
      throw "Oops..."
    end

    {:update_appending => component_session[:count].to_s}
  end

end