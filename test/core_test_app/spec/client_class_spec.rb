require 'spec_helper'

class MyComponent < Netzke::Base
  js_configure do |c|
    c.title = "My stupid component"
  end
end

describe Netzke::Core::ClientClass do
  it "should allow reading class-level properties" do
    MyComponent.js_config.title.should == "My stupid component"
  end

  it "should return nil when non-existing property is requested" do
    MyComponent.js_config.foo.should be_nil
  end
end
