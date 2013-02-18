require 'spec_helper'

class HasMultipleJsConfigures < Netzke::Base
  js_configure do |c|
    c.title = "Original"
    c.some_property = :some_property
  end

  # because this could be done from an included module
  js_configure do |c|
    c.title = "Overridden"
    c.another_property = :another_property
  end
end

describe Netzke::Core::Javascript do
  it "should provide JS config from a component instance" do
    c = Netzke::Core::Panel.new
    c.js_config.should be_present
  end

  it "should evaluate js_configure class-level block late" do
    ConfigurableOnClassLevel.title = "Overridden"
    ConfigurableOnClassLevel.js_config.title.should == "Overridden"
  end

  it "should evaluate all js_configure blocks" do
    c = HasMultipleJsConfigures.js_config
    c.title.should == "Overridden"
    c.some_property.should == :some_property
    c.another_property.should == :another_property
  end
end
