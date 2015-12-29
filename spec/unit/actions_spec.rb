require 'spec_helper'

module Netzke::Core
  describe Actions do
    class SomeComponent < Netzke::Base
      action :action_one
      action :action_two
      action :action_three do |a|
        a.text = "Action three"
      end

      def configure(c)
        super
        c.tbar = [:action_one, :action_two, :action_three]
      end

      def actions
        super.deep_merge({
          :action_four => {:text => "Action 4"}
        })
      end

      action :action_five do |a|
        a.text = "Action 5"
      end

      action :action_six do |c|
        c.text = c.name.humanize + " text"
      end
    end

    class ExtendedComponent < SomeComponent
    end

    class AnotherExtendedComponent < ExtendedComponent
      action :action_one do |a|
        a.text = "Action 1"
      end

      action :action_five do |a|
        a.text = "Action Five"
      end

      action :action_two do |c|
        super(c)
        c.disabled = true
        c.text = c.text + ", extended"
      end

      action :action_three do |a|
        a.text = "Action 3"
      end
    end

    class YetAnotherExtendedComponent < AnotherExtendedComponent
      action :action_two do |c|
        super(c)
        c.disabled = false
      end
    end

    it "extends action config" do
      actions = SomeComponent.new.actions
      expect(actions[:action_one].keys).to include(:name, :text, :tooltip)
    end

    it "autos collect actions from both js_methods and config" do
      component = SomeComponent.new
      expect(component.actions[:action_one][:text]).to eql "Action one"
      expect(component.actions[:action_two][:text]).to eql "Action two"
      expect(component.actions[:action_three][:text]).to eql "Action three"
      expect(component.actions[:action_four][:text]).to eql "Action 4"
      expect(component.actions[:action_five][:text]).to eql "Action 5"
      expect(component.actions[:action_six][:text]).to eql "Action six text"
    end

    it "does not override previous actions when reconfiguring bars in child class" do
      component = ExtendedComponent.new
      expect(component.actions[:action_one][:text]).to eql "Action one"
      expect(component.actions[:action_two][:text]).to eql "Action two"
      expect(component.actions[:action_three][:text]).to eql "Action three"
      expect(component.actions[:action_four][:text]).to eql "Action 4"
      expect(component.actions[:action_five][:text]).to eql "Action 5"
    end

    it "does not override actions in child class" do
      component = AnotherExtendedComponent.new
      expect(component.actions[:action_one][:text]).to eql "Action 1"
      expect(component.actions[:action_five][:text]).to eql "Action Five"

      expect(component.actions[:action_two][:text]).to eql "Action two, extended"
      expect(component.actions[:action_two][:disabled]).to eql true

      expect(component.actions[:action_three][:text]).to eql "Action 3"
    end

    it "should only override the specified actions" do
      component = YetAnotherExtendedComponent.new
      expect(component.actions[:action_two][:disabled]).to eql false
      expect(component.actions[:action_two][:text]).to eql "Action two, extended"
    end
  end
end
