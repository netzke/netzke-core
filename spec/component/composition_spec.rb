require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Composition do
    class SomeComponent < Base
      endpoint :method_one
      endpoint :method_two

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
    
    class ComponentOne < Base
    end
    
    class ComponentTwo < Base
    end
    
    class SomeComposite < Base
      component :component_one do
        {
          :class_name => "ComponentOne",
          :title => "My Cool Component"
        }
      end
      
      def config
        {
          :items => [
            {:class_name => "ComponentTwo", :name => "my_component_two"}, 
            {:class_name => "ComponentTwo"} # name omitted, will be "component_two1"
          ]
        }.deep_merge super
      end
    end

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
    
    it "should be possible to define nested components in different ways" do
      composite = SomeComposite.new
      components = composite.components
      
      components.keys.size.should == 3
      components[:component_one][:class_name].should == "ComponentOne"
      components[:my_component_two][:class_name].should == "ComponentTwo"
      components[:component_two1][:class_name].should == "ComponentTwo"
      
    end
    
    it "should be possible to override the superclass's declaration of a component" do
      composite = SomeComposite.new
      composite.components[:component_one][:title].should == "My Cool Component"
      
      class ExtendedComposite < SomeComposite
        component :component_one do |orig|
          orig.merge(:title => orig[:title] + ", extended")
        end
        
        component :component_two do
          {:title => "Another Nested Component"}
        end
      end
      
      extended_composite = ExtendedComposite.new
      extended_composite.components[:component_one][:title].should == "My Cool Component, extended"
      extended_composite.components[:component_one][:class_name].should == "ComponentOne"
      extended_composite.components[:component_two][:title].should == "Another Nested Component"
    end
  end  
end