# Not used in tests
class SimpleComposite < Netzke::Base
  def configure(c)
    c.layout = :fit
    c.items = [:child]
    super
  end

  component :child do |c|
    c.klass = SimpleComponent
  end
end
