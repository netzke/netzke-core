require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Netzke::Base::Composition do
    class SomeComponent < Base
      api :method_one, :method_two

      def self.config
        super.merge({
          :pref_one => 1,
          :pref_two => 2
        })
      end

      def components
        {
          :nested_one => {:class_name => 'NestedComponentOne'},
          :nested_two => {:class_name => 'NestedComponentTwo'}
        }
      end

      def available_permissions
        %w(read update)
      end

      def default_config
        {
          :config_uno => true,
          :config_dos => false
        }
      end
    end

    class NestedComponentOne < Base
    end

    class NestedComponentTwo < Base
      def components
        {
          :nested => {:class_name => 'DeepNestedComponent'}
        }
      end
    end

    class DeepNestedComponent < Base
      def components
        {
          :nested => {:class_name => "VeryDeepNestedComponent"}
        }
      end
    end

    class VeryDeepNestedComponent < Base
    end

    describe "component_instance" do
      it "should be possible to create (nested) component instances" do
        component = SomeComponent.new(:name => 'some_component')

        # instantiate components
        nested_component_one = component.component_instance(:nested_one)
        nested_component_two = component.component_instance(:nested_two)
        deep_nested_component = component.component_instance(:nested_two__nested)

        nested_component_one.class.should == NestedComponentOne
        nested_component_two.class.should == NestedComponentTwo
        deep_nested_component.class.should == DeepNestedComponent

        component.global_id.should == 'some_component'
        nested_component_one.global_id.should == 'some_component__nested_one'
        nested_component_two.global_id.should == 'some_component__nested_two'
        deep_nested_component.global_id.should == 'some_component__nested_two__nested'
      end
    end
  end  
end