class SimpleComposite < Netzke::Base
  def configure(c)
    super
    c.items = [:child.component]
  end

  component :child, :class_name => "SimpleComponent"
end
