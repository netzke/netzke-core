require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Netzke::Widget::Aggregation do
    class SomeWidget < Widget::Base
    end
    class InheritedWidget < SomeWidget
    end
  
    describe "js_inheritance?" do
      InheritedWidget.js_inheritance?.should == true
    end
  end  
end