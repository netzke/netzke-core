require 'spec_helper'

describe "Any component" do
  class TestComponent < Netzke::Base
    endpoint :some_action do |params, this|
    end
  end

  it "should be able to register endpoints" do
    TestComponent.endpoints.should include :some_action
  end

  it "should have deliver_component endpoint by default" do
    TestComponent.endpoints.should include :deliver_component
  end
end
