require 'spec_helper'

module Netzke::Core
  describe Composition do
    class SomeComposite < Netzke::Base
      component :nested_one do |c|
        c.klass = NestedComponentOne
      end

      component :nested_two do |c|
        c.klass = NestedComponentTwo
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

    class ComponentTwo < Netzke::Base
    end

    class BaseComposite < Netzke::Base
      component :component_one do |c|
        c.klass = ComponentOne
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

    class ComponentWithExcluded < Netzke::Base
      component :accessible
      component :inaccessible do |c|
        c.excluded = true
      end
    end

    it "should be possible to create (nested) component instances" do
      component = SomeComposite.new(:name => 'some_composite')

      # instantiate components
      nested_component_one = component.component_instance(:nested_one)
      nested_component_two = component.component_instance(:nested_two)
      deep_nested_component = component.component_instance(:nested_two__nested)

      nested_component_one.class.should == NestedComponentOne
      nested_component_two.class.should == NestedComponentTwo
      deep_nested_component.class.should == DeepNestedComponent

      component.js_id.should == 'some_composite'
      nested_component_one.js_id.should == 'some_composite__nested_one'
      nested_component_two.js_id.should == 'some_composite__nested_two'
      deep_nested_component.js_id.should == 'some_composite__nested_two__nested'
    end

     it "should be possible to override the superclass's declaration of a component" do
       composite = BaseComposite.new
       composite.components[:component_one][:title].should == "My Cool Component"

       extended_composite = ExtendedComposite.new
       extended_composite.components[:component_one][:title].should == "My Cool Component, extended"
       extended_composite.components[:component_one][:klass].should == ComponentOne
       extended_composite.components[:component_two][:title].should == "Another Nested Component"
     end

     it "should be impossible to access excluded components" do
       c = ComponentWithExcluded.new
       c.components.should have_key(:accessible)
       c.components.should_not have_key(:inaccessible)
     end
  end
end
