class HelloUser < HelloWorld
  def configure(c)
    c.user = client_config[:user_name] || 'Max'
    super
    c.title = "Configured with user #{c.user}"
  end

  endpoint :greet_the_world do
    client.show_greeting("Hello #{config.user}!")
  end
end
