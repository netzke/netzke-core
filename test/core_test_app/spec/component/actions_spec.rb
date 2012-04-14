require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Actions do
    # it "should be possible to override toolbars without overriding action settings" do
    #   ExtendedComponentWithActions.new.actions[:another_action][:disabled].should == true
    # end

    class SomeComponent < Base
      action :action_one
      action :action_two
      action :action_three do
        {:text => "Action three"}
      end

      js_property :bbar, [:action_one, :action_two]

      def config
        {
          :tbar => [:action_three]
        }
      end

      def actions
        super.deep_merge({
          :action_four => {:text => "Action 4"}
        })
      end

      action :action_five, :text => "Action 5"
    end

    class ExtendedComponent < SomeComponent
      js_property :bbar, [:action_one, :action_two, :action_three, :action_four, :action_five]
      js_property :tbar, [:action_one, :action_two, :action_three, :action_four, :action_five]
    end

    class AnotherExtendedComponent < ExtendedComponent
      action :action_one, :text => "Action 1"
      action :action_five, :text => "Action Five"

      def action_two_action
        super.merge(:disabled => true, :text => normalize_action_config(super)[:text] + ", extended")
      end

      action :action_three do
        {:text => "Action 3"}
      end
    end

    class YetAnotherExtendedComponent < AnotherExtendedComponent
      action :action_two, :disabled => false
    end

    # it "should auto collect actions from both js_methods and config" do
    #   component = SomeComponent.new
    #   component.actions.keys.size.should == 5
    #   component.actions[:action_one][:text].should == "Action one"
    #   component.actions[:action_two][:text].should == "Action two"
    #   component.actions[:action_three][:text].should == "Action three"
    #   component.actions[:action_four][:text].should == "Action 4"
    #   component.actions[:action_five][:text].should == "Action 5"
    # end

    it "should not override previous actions when reconfiguring bars in child class" do
      component = ExtendedComponent.new
      # component.actions.keys.size.should == 5
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