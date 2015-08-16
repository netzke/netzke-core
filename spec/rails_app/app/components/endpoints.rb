class Endpoints < Netzke::Base
  action :with_response
  action :no_response
  action :multiple_argument_response
  action :array_as_argument
  action :return_value
  action :non_existing
  action :multiple_arguments
  action :hash_argument
  action :batched_call

  # this action is using generic endpoint callback with scope
  action :callback_and_scope

  js_configure do |c|
    c.title = "Endpoints"
    c.mixin
  end

  def configure(c)
    super
    c.bbar = [:with_response, :no_response, :multiple_argument_response, :array_as_argument, :callback_and_scope, :return_value, :non_existing, :multiple_arguments]
    c.tbar = [:hash_argument, :batched_call]
  end

  endpoint :whats_up do |greeting|
    this.set_title("Hello #{greeting}")
    "Hello from the server!"
  end

  endpoint :multiple_argument_response do
    this.take_two_arguments("First argument", "Second argument")
  end

  endpoint :array_as_argument do
    this.take_array_as_argument(['Element 1', 'Element 2'])
  end

  endpoint :do_nothing do
  end

  endpoint :get_answer do
    42
  end

  endpoint :server_non_existing do
    # won't get here
  end

  endpoint :server_multiple_arguments do |one, two, three|
    [one, two, three].join(', ')
  end

  endpoint :server_hash_argument do |hash|
    [hash["one"], hash["two"]].join(', ')
  end

  endpoint :server_set_foo do
    this.setTitle('foo')
  end

  endpoint :server_append_bar do
    this.appendTitle('bar')
  end

  def invoke_endpoint(ep, *params, configs)
    if ep == "server_non_existing"
      ep = "non_existing_child__endpoint"
    end

    super ep, *params, configs
  end
end
