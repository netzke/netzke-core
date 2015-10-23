class BufferedRequest < Netzke::Base
  client_class do |c|
    c.layout = :hbox
  end

  action :buffered_call

  component :jim do |c|
    c.klass = HelloUser
    c.user = 'Jim'
    c.height = "100%"
    c.flex = 1
  end

  component :bill do |c|
    c.klass = HelloUser
    c.user = 'Bill'
    c.height = "100%"
    c.flex = 1
  end

  def configure(c)
    super
    c.items = [ :jim, :bill ]

    c.bbar = [:buffered_call]
  end
end
