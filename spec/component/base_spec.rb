require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

describe Netzke::Base do
  it "should keep config independent inside class hierarchy" do
    class Parent < Netzke::Base; end
    class Child < Parent; end
    
    Parent.configure :a_setting => 100
    Child.configure :a_setting => 200
    
    Parent.config[:a_setting].should == 100
    Child.config[:a_setting].should == 200
  end
end  
