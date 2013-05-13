class Endpoints < Netzke::Base
  action :with_response
  action :no_response
  action :multiple_arguments
  action :array_as_argument
  action :return_value
  action :non_existing

  # this action is using generic endpoint callback with scope
  action :callback_and_scope

  js_configure do |c|
    c.title = "Endpoints"
    c.mixin
  end

  def configure(c)
    super
    c.bbar = [:with_response, :no_response, :multiple_arguments, :array_as_argument, :callback_and_scope, :return_value, :non_existing]

    # Alternative way of defining bbar:
    # c.docked_items = [{
    #   xtype: :toolbar,
    #   dock: :right,
    #   items: [:with_response, :no_response, :multiple_arguments, :array_as_argument]
    # }]
  end

  endpoint :whats_up do |params, this|
    this.set_title("Response from server")
  end

  endpoint :no_response do |params, this|
  end

  endpoint :multiple_arguments do |params, this|
    this.take_two_arguments("First argument", "Second argument")
  end

  endpoint :array_as_argument do |params, this|
    this.take_array_as_argument(['Element 1', 'Element 2'])
  end

  endpoint :do_nothing do |params,this|
  end

  endpoint :get_answer do |params,this|
    raise "params expected to be null" if !params.nil?
    this.netzke_set_result(42) # special method that passes a value as argument to callback function
  end

  endpoint :server_non_existing do |params, this|
    # won't get here
  end

  def invoke_endpoint(ep, params, configs)
    if ep == "server_non_existing"
      ep = "non_existing_child__endpoint"
    end

    super ep, params, configs
  end
end
