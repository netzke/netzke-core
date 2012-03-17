class SimpleComposite < Netzke::Base
  def configure!
    super
    @config[:items] = [:child.component]
  end

  component :child, :class_name => "SimpleComponent"
end
