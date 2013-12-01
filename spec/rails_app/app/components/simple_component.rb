class SimpleComponent < Netzke::Base
  def configure(c)
    c.bbar = ["Hello"]
    c.title = c.client_config[:title] || "SimpleComponent"
    super
  end
end
