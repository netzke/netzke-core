require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Javascript do
    class SomeComponent < Base
    end
    class InheritedComponent < SomeComponent
    end

    it "should be indicated by extends_netzke_component? if we're extending a Netzke component" do
      SomeComponent.send(:"extends_netzke_component?").should == false
      InheritedComponent.send(:"extends_netzke_component?").should == true
    end
  end
end