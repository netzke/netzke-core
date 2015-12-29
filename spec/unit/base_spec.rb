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
  it "preserves class config within class hierarchy" do
    expect(Parent.with_feature).to eql "yes"
    expect(Child.with_feature).to eql "yes"

    Child.with_feature = "no"

    expect(Parent.with_feature).to eql "yes"
    expect(Child.with_feature).to eql "no"

    Parent.with_feature = "maybe"
    expect(Parent.with_feature).to eql "maybe"
    expect(Child.with_feature).to eql "no"
  end

  it "returns correct i18n_id" do
    expect(Netzke::MyComponents::CoolComponent.i18n_id).to eql "netzke.my_components.cool_component"
  end
end
