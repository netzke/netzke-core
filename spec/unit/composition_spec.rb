require 'spec_helper'

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

class ::ComponentTwo < Netzke::Base
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
  component :accessible do |c|
    c.klass = Netzke::Core::Panel
  end
  component :inaccessible do |c|
    c.klass = Netzke::Core::Panel
    c.excluded = true
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

module Netzke::Core
  describe Composition do
    it "should set item_id to component's name by default" do
      component = SomeComposite.new(:name => 'some_composite')
      component.components[:nested_one][:item_id].should == "nested_one"
    end

    it "should be possible to override the superclass's declaration of a component" do
      composite = BaseComposite.new
      composite.components[:component_one][:title].should == "My Cool Component"

      extended_composite = ExtendedComposite.new
      extended_composite.components[:component_one][:title].should == "My Cool Component, extended"
      extended_composite.components[:component_one][:klass].should == ComponentOne
      extended_composite.components[:component_two][:title].should == "Another Nested Component"
    end

    it "should be impossible to access excluded component config" do
      c = ComponentWithExcluded.new
      c.components[:inaccessible].should == {excluded: true}
    end

    describe "inline nesting" do
      it "has correct keys of dynamically added components" do
        comp = InlineNesting.new
        expect(comp.js_components.keys).to eql [:component_1, :component_2]
      end

      it "has correct children keys of dynamically added nested components" do
        comp = InlineNesting.new
        child = comp.component_instance(:component_1)
      end
    end
  end
end
