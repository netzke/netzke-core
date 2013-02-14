class SimpleComponent < Netzke::Base
  js_configure do |c|
    c.html = "Inner text"
  end

  def configure(c)
    c.bbar = ["Hello"]
    c.title = "SimpleComponent"
    super
  end
end
