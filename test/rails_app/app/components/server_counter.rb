class ServerCounter < Netzke::Base
  action :count_one_time # 1 request
  action :count_seven_times # 7 requests (should be batched)
  action :count_eight_times_special # passing multiple arguments
  action :fail_in_the_middle # calls 3 endpoints of which the second fails
  action :do_ordered # used for test if call order is preserved
  action :fail_two_out_of_five # sends 5 requests, 2 will fail, but the request should be processed in order

  js_properties(
    :title => "Server Counter",
    :bbar => [:count_one_time.action, :count_seven_times.action, :count_eight_times_special.action, :fail_in_the_middle.action, :do_ordered.action, :fail_two_out_of_five.action]
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

  js_method :on_fail_two_out_of_five, <<-JS
    function(){
      for(var i=1; i<=5; i++) {
        this.failTwoOutOfFive(i);
      }
    }
  JS

  def before_load
    component_session[:is_retry] = false
    component_session[:count] = 0
  end

  endpoint :count do |params|
    component_session[:count] ||= 0
    component_session[:count] += params[:how_many]
    {:update => "I am at " + component_session[:count].to_s + (params[:special] ? ' and i was invoked specially' : '')}
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

  endpoint :fail_two_out_of_five do |count|
    component_session[:count] ||= 0
    component_session[:count] += 1

    # 2nd and 4th request fail, but only first time, not at a retry
    if ([2,4].include?(component_session[:count]) && !component_session[:is_retry])
      component_session[:is_retry] = true
      throw "Oops..."
    end

    component_session[:is_retry] = false
    {:update_appending => count}
  end

end
