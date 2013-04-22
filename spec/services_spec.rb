require 'spec_helper'

class TestComponent < Netzke::Base
  endpoint :some_action do |params, this|
  end
end

describe Netzke::Core::Services do
  it "should be able to register endpoints" do
    TestComponent.endpoints.should include :some_action
  end

  it "should have deliver_component endpoint" do
    TestComponent.endpoints.should include :deliver_component
  end
end
