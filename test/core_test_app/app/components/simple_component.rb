class SimpleComponent < Netzke::Base
  def configure(c)
    c.bbar = ["Hello"]
    c.title = "SimpleComponent"
    super
  end
end
