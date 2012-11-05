class ServerCounter < Netzke::Base
  action :count_one_time # 1 request
  action :count_seven_times # 7 requests (should be batched)
  action :count_eight_times_special # passing multiple arguments
  action :fail_in_the_middle # calls 3 endpoints of which the second fails
  action :do_ordered # used for test if call order is preserved
  action :fail_two_out_of_five # sends 5 requests, 2 will fail, but the request should be processed in order

  js_configure do |c|
    c.mixin
  end

  def configure(c)
    super
    c.bbar = [:count_one_time, :count_seven_times, :count_eight_times_special, :fail_in_the_middle, :do_ordered, :fail_two_out_of_five]
    c.title "Server Counter"
  end

  endpoint :count do |params, this|
    component_session[:count] ||= 0
    component_session[:count] += params[:how_many]
    this.update_content("I am at " + component_session[:count].to_s + (params[:special] ? ' and i was invoked specially' : ''))
  end

  endpoint :successing_endpoint do |params, this|
    this.update_content("Something successed ")
  end

  endpoint :failing_endpoint do |params, this|
    throw "something happened"
  end

  endpoint :first_ep do |params, this|
    component_session[:count]||=0
    component_session[:count]+=1
    this.update_content("First. "+ component_session[:count].to_s)
  end

  endpoint :second_ep do |params, this|
    component_session[:count]||=0
    component_session[:count]+=1
    this.update_content("Second. "+ component_session[:count].to_s)
  end

  endpoint :fail_two_out_of_five do |count, this|
    component_session[:count] ||= 0
    component_session[:count] += 1

    # 2nd and 4th request fail, but only first time, not at a retry
    if ([2,4].include?(component_session[:count]) && !component_session[:is_retry])
      component_session[:is_retry] = true
      throw "Oops..."
    end

    component_session[:is_retry] = false
    this.update_appending(count)
  end

end
