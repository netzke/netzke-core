require 'spec_helper'

class TestComponent < Netzke::Base
  endpoint :some_action do
  end
end

describe Netzke::Core::Services do
  it "should be able to register endpoints" do
    expect(TestComponent.endpoints).to include :some_action
  end

  it "should have deliver_component endpoint" do
    expect(TestComponent.endpoints).to include :deliver_component
  end
end
