class HelloUser < HelloWorld
  def configure(c)
    c.user = client_config[:user_name] || 'Max'
    super
    c.title = "Configured with user #{client_config[:user_name]}"
  end

  endpoint :greet_the_world do
    this.show_greeting("Hello #{config.user}!")
  end
end
