require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

describe Netzke::Configuration do
  it "should be able to configure components on the class level" do

    Netzke::Core.config = Netzke::Core::OptionsHash.new
    Netzke::Core.config.my_components.component_one.to_override = 2
    Netzke::Core.config.my_components.component_one.another_to_override = 20

    Netzke::Core.config.my_components.component_one.options_set.option_three = "three"
    Netzke::Core.config.my_components.component_one.options_set.option_four = 4

    Netzke::Core.config.my_components.child_component_one.to_override = 4

    module Netzke
      module MyComponents
        class ComponentOne < Netzke::Base
          class_config_option :amount_cool_things, 100
          class_config_option :with_cool_feature, true
          class_config_option :to_override, 1
          class_config_option :another_to_override, 10

          class_config_option :options_set, {
            :option_one => 1,
            :option_two => 2,
            :option_three => 3
          }
        end

        class ChildComponentOne < ComponentOne
          class_config_option :with_cool_feature, false
          class_config_option :with_another_cool_feature, true
          class_config_option :to_override, 3 # in order to make this configurable, we need to declare it again (not enough to have declaration in the parent class)
          self.another_to_override = 30 # freeze this config option for this class - it'll not be configurable
        end

      end
    end

    Netzke::MyComponents::ComponentOne.amount_cool_things.should == 100
    Netzke::MyComponents::ComponentOne.with_cool_feature.should be_true
    Netzke::MyComponents::ComponentOne.to_override.should == 2
    Netzke::MyComponents::ComponentOne.another_to_override.should == 20

    Netzke::MyComponents::ComponentOne.options_set.should == {
      :option_one => 1,
      :option_two => 2,
      :option_three => "three",
      :option_four => 4
    }

    Netzke::MyComponents::ChildComponentOne.amount_cool_things.should == 100
    Netzke::MyComponents::ChildComponentOne.to_override.should == 4
    Netzke::MyComponents::ChildComponentOne.with_cool_feature.should be_false
    Netzke::MyComponents::ChildComponentOne.with_another_cool_feature.should be_true
    Netzke::MyComponents::ChildComponentOne.another_to_override.should == 30

  end

end