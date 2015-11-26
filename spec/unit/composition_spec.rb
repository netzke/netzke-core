require 'spec_helper'
require_relative './components/composition_spec_components'

# Test components are declared in composition_spec_components.rb
module Netzke::Core
  describe Composition do
    describe "#component_instance" do
      it "returns component instance by symbol or string" do
        composite = BaseComposite.new
        expect(composite.component_instance(:component_one)).to be_a(ComponentOne)
        expect(composite.component_instance("component_one")).to be_a(ComponentOne)
      end
    end

    describe "#dependency_classes" do
      it "returns classes for components that our JS instance depends on" do
        subj = SuperComposite.new.dependency_classes
        expect(subj).to include(SuperComposite, ComponentTwo, ExtendedComposite, BaseComposite)
      end
    end

    it "derrives component's class from its name by default" do
      expect(BaseComposite.new.component_instance(:component_one)).to be_a(ComponentOne)
    end

    it "sets item_id to component's name by default" do
      component = BaseComposite.new
      expect(component.component_instance(:first_component_two).item_id).to eql "first_component_two"
    end

    it "allows overriding superclass's declaration of a component" do
      composite = BaseComposite.new
      component_one = composite.component_instance(:component_one)
      expect(component_one.js_config[:title]).to eql "My Cool Component"

      extended_composite = ExtendedComposite.new
      expect(extended_composite.component_instance(:component_one).js_config[:title]).to eql "My Cool Component, extended"
      expect(extended_composite.component_instance(:component_one).class).to eql ComponentOne
      expect(extended_composite.component_instance(:component_two).js_config[:title]).to eql "Another Nested Component"
    end

    xit "does not allow accessing excluded component's config" do
      c = ComponentWithExcluded.new
      inaccessible = c.component_instance(:inaccessible)
      puts "\n!!! inaccessible: #{inaccessible.js_config.inspect}"
      # c.components[:inaccessible].should == {excluded: true}
    end

    describe "inline nesting" do
      it "has correct keys of dynamically added components" do
        comp = InlineNesting.new
        expect(comp.js_components.keys).to eql [:component_0, :component_1]
      end

      it "has correct children keys of dynamically added nested components" do
        comp = InlineNesting.new
        child = comp.component_instance(:component_0)
        expect(child.js_components.keys).to eql [:component_0, :component_1]
      end

      it "marks inline-defined components as egarly loaded" do
        comp = InlineNesting.new
        expect(comp.eagerly_loaded_components).to include(:component_0, :component_1)
      end
    end

    describe "#component_config" do
      it "returns nil is nil is given as component_name" do
        comp = SomeComposite.new
        expect(comp.component_config(nil)).to be_nil
      end

      it "returns config for components declared with DSL" do
        comp = SomeComposite.new
        expect(comp.component_config(:nested_one)[:klass]).to eql NestedComponentOne
      end

      it "returns config for components declared inline in config" do
        comp = InlineComposite.new
        config = comp.component_config(:one)
        expect(config[:klass]).to eql ComponentOne
        expect(config[:title]).to eql 'Declared inline'
      end

      it "returns inline component config by symbol or string" do
        comp = InlineComposite.new
        expect(comp.component_config(:one)).to be_a(Hash)
        expect(comp.component_config("one")).to be_a(Hash)
      end
    end

    describe "#eagerly_loaded_components" do
      it "returns eagerly loaded component names" do
        comp = HybridComposite.new
        subj = comp.eagerly_loaded_components
        expect(subj).to include(:eagerly_loaded, :component_one, :component_0)
      end

      it "returns eagerly loaded components extended inline" do
        comp = ExtendChildrenConfig.new
        subj = comp.eagerly_loaded_components
        expect(subj).to include(:component_one)
      end
    end

    describe "#extend_item" do
      it "converts 'component' key to 'netzke_component'" do
        client_config = SomeComposite.new.js_config[:items]
        expect(client_config[0]).to have_key(:netzke_component)
        expect(client_config[0]).to_not have_key(:component)
        expect(client_config[1]).to have_key(:netzke_component)
        expect(client_config[1]).to_not have_key(:component)
      end
    end
  end
end
