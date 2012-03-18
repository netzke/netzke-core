class SimpleComponent < Netzke::Base
  title "SimpleComponent!"
  js_properties :html  => "Inner text"

  def configure
    super
    @config[:bbar] = ["Hello"]
  end
end
