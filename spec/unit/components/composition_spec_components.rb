class SomeComposite < Netzke::Base
  component :nested_one do |c|
    c.klass = NestedComponentOne
  end

  component :nested_two do |c|
    c.klass = NestedComponentTwo
  end

  def configure(c)
    super
    c.items = [:nested_one, {component: :nested_two}]
  end
end

class NestedComponentOne < Netzke::Base
end

class NestedComponentTwo < Netzke::Base
  component :nested do |c|
    c.klass = DeepNestedComponent
  end
end

class DeepNestedComponent < Netzke::Base
  component :nested do |c|
    c.klass = VeryDeepNestedComponent
  end
end

class VeryDeepNestedComponent < Netzke::Base
end

class ComponentOne < Netzke::Base
end

class ::ComponentTwo < Netzke::Base
end

class BaseComposite < Netzke::Base
  component :component_one do |c|
    c.title = "My Cool Component"
  end

  component :first_component_two do |c|
    c.klass = ComponentTwo
  end

  component :second_component_two do |c|
    c.klass = ComponentTwo
  end

  def configure(c)
    super
    c.items = [ :first_component_two, :second_component_two ]
  end
end

class ExtendedComposite < BaseComposite
  component :component_one do |c|
    super c
    c.title = c.title + ", extended"
  end

  component :component_two do |c|
    c.title = "Another Nested Component"
  end
end

# Includes composite component
class SuperComposite < Netzke::Base
  component :extended_composite, eager_load: true
end

class ComponentWithExcluded < Netzke::Base
  component :accessible do |c|
    c.klass = Netzke::Core::Panel
  end

  component :inaccessible do |c|
    c.klass = Netzke::Core::Panel
    c.excluded = true
  end

  def configure(c)
    super
    c.items = [:accessible, :inaccessible]
  end
end

class InlineComposite < Netzke::Base
  def configure(c)
    super
    c.items = [
      {
        klass: ComponentOne,
        title: "Declared inline",
        item_id: "one"
      }
    ]
  end
end

class InlineNesting < Netzke::Base
  def configure(c)
    super
    c.items = [
      {
        klass: ComponentOne,
        items: [
          { klass: ComponentOne },
          { klass: ComponentOne }
        ]
      },
      {
        klass: ComponentOne
      }
    ]
  end
end

class HybridComposite < Netzke::Base
  component :component_one
  component :component_two

  component :eagerly_loaded, eager_load: true do |c|
    c.klass = ComponentOne
  end

  def configure(c)
    super
    c.items = [:component_one, {klass: ComponentOne}]
  end
end

class ExtendChildrenConfig < Netzke::Base
  component :component_one

  def configure(c)
    super
    c.items = [{foo: 'bar', component: :component_one}]
  end
end
