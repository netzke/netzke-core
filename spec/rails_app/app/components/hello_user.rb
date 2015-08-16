class HelloUser < HelloWorld
  def configure(c)
    c.user = 'Max'
    super
    c.title = "Configured with user #{c.user}"
  end

  endpoint :greet_the_world do
    this.show_greeting("Hello #{config.user}!")
  end
end
