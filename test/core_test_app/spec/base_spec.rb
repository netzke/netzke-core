require 'spec_helper'

class Parent < Netzke::Base
  class_attribute :with_feature
  self.with_feature = "yes"
end

class Child < Parent; end

module Netzke
  module MyComponents
    class CoolComponent < Netzke::Base
    end
  end
end

describe Netzke::Base do
  it "should preserve class config within class hierarchy" do
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
    Netzke::MyComponents::CoolComponent.i18n_id.should == "netzke.my_components.cool_component"
  end
end
