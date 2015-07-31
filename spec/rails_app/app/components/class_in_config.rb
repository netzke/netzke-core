# Some edge case when passing a class as param and using it in a component causes stack overflow due to some JSON
# encoding infinite loops
class ClassInConfig < Netzke::Base
  component :child do |c|
    c.klass = config[:child_class]
  end

  def configure(c)
    c.child_class = SimplePanel
    super
    c.items = [:child]
  end
end
