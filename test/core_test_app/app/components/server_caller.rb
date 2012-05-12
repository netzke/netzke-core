class ServerCaller < Netzke::Base
  action :bug_server # Actual action's text is set in en.yml
  action :no_response
  action :multiple_arguments
  action :array_as_argument

  js_mixin

  js_properties(
    :title => "Server Caller",
    :html => "Wow"
  )

  def configure
    super
    config.tbar = [:bug_server, :no_response, :multiple_arguments, :array_as_argument]
    config.title = "Server Caller!"
  end

  endpoint :whats_up do |params, this|
    this.set_title("All quiet here on the server")
  end

  endpoint :no_response do |params, this|
  end

  endpoint :multiple_arguments do |params, this|
    this.take_two_arguments("First argument", "Second argument")
  end

  endpoint :array_as_argument do |params, this|
    this.take_array_as_argument(['Element 1', 'Element 2'])
  end
end
