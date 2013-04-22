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

    it "should auto collect actions from both js_methods and config" do
      component = SomeComponent.new
      component.actions[:action_one][:text].should == "Action one"
      component.actions[:action_two][:text].should == "Action two"
      component.actions[:action_three][:text].should == "Action three"
      component.actions[:action_four][:text].should == "Action 4"
      component.actions[:action_five][:text].should == "Action 5"
      component.actions[:action_six][:text].should == "Action six text"
    end

    it "should not override previous actions when reconfiguring bars in child class" do
      component = ExtendedComponent.new
      component.actions[:action_one][:text].should == "Action one"
      component.actions[:action_two][:text].should == "Action two"
      component.actions[:action_three][:text].should == "Action three"
      component.actions[:action_four][:text].should == "Action 4"
      component.actions[:action_five][:text].should == "Action 5"
    end

    it "should be possible to override actions in child class" do
      component = AnotherExtendedComponent.new
      component.actions[:action_one][:text].should == "Action 1"
      component.actions[:action_five][:text].should == "Action Five"

      component.actions[:action_two][:text].should == "Action two, extended"
      component.actions[:action_two][:disabled].should == true

      component.actions[:action_three][:text].should == "Action 3"
    end

    it "should only override the specified actions" do
      component = YetAnotherExtendedComponent.new
      component.actions[:action_two][:disabled].should == false
      component.actions[:action_two][:text].should == "Action two, extended"
    end

  end
end
