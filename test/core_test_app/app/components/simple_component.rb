class SimpleComponent < Netzke::Base
  js_properties :html  => "Inner text"

  def configure
    super
    config.bbar = ["Hello"]
    config.title "SimpleComponent!"
  end
end
