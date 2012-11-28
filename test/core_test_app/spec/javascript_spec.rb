require 'spec_helper'

describe Netzke::Core::Javascript do
  it "should provide JS config from a component instance" do
    c = Netzke::Core::Panel.new
    c.js_config.should be_present
  end

  it "should evaluate js_configure class-level block late" do
    ConfigurableOnClassLevel.title = "Overridden"
    ConfigurableOnClassLevel.js_config.title.should == "Overridden"
  end
end
