require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Netzke::Component::Composition do
    class SomeComponent < Component::Base
    end
    class InheritedComponent < SomeComponent
    end
  
    describe "extends_netzke_component?" do
      InheritedComponent.extends_netzke_component?.should == true
    end
  end  
end