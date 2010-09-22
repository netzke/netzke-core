require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Netzke::Component::Composition do
    class SomeComponent < Component::Base
      api :method_one, :method_two

      def self.config
        super.merge({
          :pref_one => 1,
          :pref_two => 2
        })
      end

      def aggregatees
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

    class NestedComponentOne < Component::Base
    end

    class NestedComponentTwo < Component::Base
      def aggregatees
        {
          :nested => {:class_name => 'DeepNestedComponent'}
        }
      end
    end

    class DeepNestedComponent < Component::Base
      def aggregatees
        {
          :nested => {:class_name => "VeryDeepNestedComponent"}
        }
      end
    end

    class VeryDeepNestedComponent < Component::Base
    end

    describe "aggregatee_instance" do
      it "should be possible to create (nested) aggregatee instances" do
        component = SomeComponent.new(:name => 'some_component')

        # instantiate aggregatees
        nested_component_one = component.aggregatee_instance(:nested_one)
        nested_component_two = component.aggregatee_instance(:nested_two)
        deep_nested_component = component.aggregatee_instance(:nested_two__nested)

        # check the classes of aggregation instances
        nested_component_one.class.should == NestedComponentOne
        nested_component_two.class.should == NestedComponentTwo
        deep_nested_component.class.should == DeepNestedComponent

        # check the internal names of aggregation instances
        component.global_id.should == 'some_component'
        nested_component_one.global_id.should == 'some_component__nested_one'
        nested_component_two.global_id.should == 'some_component__nested_two'
        deep_nested_component.global_id.should == 'some_component__nested_two__nested'
      end
    end
  end  
end