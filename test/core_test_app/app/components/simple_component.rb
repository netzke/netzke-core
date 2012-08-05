class SimpleComponent < Netzke::Base
  js_configure do |c|
    c.html = "Inner text"
  end

  def configure(c)
    super
    c.bbar = ["Hello"]
    c.title "SimpleComponent!"
  end
end
