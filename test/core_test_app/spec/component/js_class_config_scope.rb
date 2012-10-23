require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

class SomeComponent < Netzke::Base
end

module MyCompanyComponents
  class SomeComponent < Netzke::Base
  end
end

class InheritedComponent < SomeComponent
end

module Netzke
  module Basepack
    class GridPanel < Netzke::Base
    end
  end
end

describe Netzke::Core::ClientClass do
  it "should build scope based on component scope" do
    SomeComponent.js_config.scope.should == "Netzke.classes"
    MyCompanyComponents::SomeComponent.js_config.scope.should == "Netzke.classes.MyCompanyComponents"
  end

  it "should properly detect whether we are extending a Netzke component" do
    SomeComponent.js_config.extending_extjs_component?.should be_true
    InheritedComponent.js_config.extending_extjs_component?.should be_false
  end

  it "should build full client class name based on class name" do
    SomeComponent.js_config.class_name.should == "Netzke.classes.SomeComponent"
    MyCompanyComponents::SomeComponent.js_config.class_name.should == "Netzke.classes.MyCompanyComponents.SomeComponent"
    Netzke::Basepack::GridPanel.js_config.class_name.should == "Netzke.classes.Netzke.Basepack.GridPanel"
  end
end
