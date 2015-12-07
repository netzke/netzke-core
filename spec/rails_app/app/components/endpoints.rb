class Endpoints < Netzke::Base
  action :with_response, :no_response, :multiple_argument_response, :array_as_argument, :return_value, :non_existing,
    :multiple_arguments, :hash_argument, :batched_call, :raise_exception, :return_error, :callback_and_scope, :callback

  client_class do |c|
    c.title = "Endpoints"
  end

  def configure(c)
    super
    c.bbar = [:with_response, :no_response, :multiple_argument_response, :array_as_argument, :callback_and_scope,
              :return_value, :non_existing, :multiple_arguments]
    c.tbar = [:hash_argument, :batched_call, :raise_exception, :return_error, :callback]
  end

  endpoint :whats_up do |greeting|
    client.set_title("Hello #{greeting}")
    "Hello from the server!"
  end

  endpoint :multiple_argument_response do
    client.take_two_arguments("First argument", "Second argument")
  end

  endpoint :array_as_argument do
    client.take_array_as_argument(['Element 1', 'Element 2'])
  end

  endpoint :do_nothing do
  end

  endpoint :get_answer do
    42
  end

  endpoint :non_existing do
    # won't get here
  end

  endpoint :multiple_arguments do |one, two, three|
    [one, two, three].join(', ')
  end

  endpoint :hash_argument do |hash|
    [hash["one"], hash["two"]].join(', ')
  end

  endpoint :set_foo do
    client.setTitle('foo')
  end

  endpoint :append_bar do
    client.appendTitle('bar')
  end

  endpoint :raise do
    raise "Exception in endpoint"
  end

  endpoint :return_error do
    { error: {type: 'CUSTOM_ERROR', msg: 'Error returned by endpoint'} }
  end

  def invoke_endpoint(ep, *params, configs)
    if ep == "non_existing"
      ep = "non_existing_child__endpoint"
    end

    super ep, *params, configs
  end
end
