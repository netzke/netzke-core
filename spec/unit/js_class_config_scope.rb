require 'spec_helper'

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

describe Netzke::Core::ClientClassConfig do
  it "builds scope based on component scope" do
    expect(SomeComponent.js_config.scope).to eql "Netzke.classes"
    expect(MyCompanyComponents::SomeComponent.js_config.scope).to eql "Netzke.classes.MyCompanyComponents"
  end

  it "detects whether we are extending a Netzke component" do
    expect(SomeComponent.js_config.extending_extjs_component?).to be_true
    expect(InheritedComponent.js_config.extending_extjs_component?).to be_false
  end

  it "builds full client class name based on class name" do
    expect(SomeComponent.js_config.class_name).to eql "Netzke.classes.SomeComponent"
    expect(MyCompanyComponents::SomeComponent.js_config.class_name).to eql "Netzke.classes.MyCompanyComponents.SomeComponent"
    expect(Netzke::Basepack::GridPanel.js_config.class_name).to eql "Netzke.classes.Netzke.Basepack.GridPanel"
  end
end
