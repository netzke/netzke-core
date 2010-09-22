require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Netzke::Component::Composition do
    class SomeComponent < Component::Base
    end
    class InheritedComponent < SomeComponent
    end
  
    describe "js_inheritance?" do
      InheritedComponent.js_inheritance?.should == true
    end
  end  
end