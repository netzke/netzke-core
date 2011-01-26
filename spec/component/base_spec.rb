require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

describe Netzke::Base do
  it "should keep config independent inside class hierarchy" do
    class Parent < Netzke::Base
      class_attribute :with_feature
      self.with_feature = "yes"
    end

    class Child < Parent; end

    Parent.with_feature.should == "yes"
    Child.with_feature.should == "yes"

    Child.with_feature = "no"

    Parent.with_feature.should == "yes"
    Child.with_feature.should == "no"

    Parent.with_feature = "maybe"
    Parent.with_feature.should == "maybe"
    Child.with_feature.should == "no"
  end

  it "should return correct i18n_id" do
    module Netzke
      module MyComponents
        class CoolComponent < Netzke::Base
        end
      end
    end

    Netzke::MyComponents::CoolComponent.new.i18n_id.should == "netzke.my_components.cool_component"
  end
end
