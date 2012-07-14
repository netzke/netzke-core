class SimpleComponent < Netzke::Base
  js_configure do |c|
    c.html = "Inner text"
  end

  def configure
    super
    config.bbar = ["Hello"]
    config.title "SimpleComponent!"
  end
end
