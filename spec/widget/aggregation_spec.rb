require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe Netzke::Widget::Aggregation do
    before :all do
      class SomeWidget < Widget::Base
        api :method_one, :method_two

        def self.config
          super.merge({
            :pref_one => 1,
            :pref_two => 2
          })
        end

        def initial_aggregatees
          {
            :nested_one => {:class_name => 'NestedWidgetOne'},
            :nested_two => {:class_name => 'NestedWidgetTwo'}
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
  
      class NestedWidgetOne < Widget::Base
      end

      class NestedWidgetTwo < Widget::Base
        def initial_aggregatees
          {
            :nested => {:class_name => 'DeepNestedWidget'}
          }
        end
      end

      class DeepNestedWidget < Widget::Base
        def initial_aggregatees
          {
            :nested => {:class_name => "VeryDeepNestedWidget"}
          }
        end
      end

      class VeryDeepNestedWidget < Widget::Base
      end
    end

    describe "aggregatee_instance" do
      it "should be possible to create (nested) aggregatee instances" do
        widget = SomeWidget.new(:name => 'some_widget')

        # instantiate aggregatees
        nested_widget_one = widget.aggregatee_instance(:nested_one)
        nested_widget_two = widget.aggregatee_instance(:nested_two)
        deep_nested_widget = widget.aggregatee_instance(:nested_two__nested)

        # check the classes of aggregation instances
        nested_widget_one.class.should == NestedWidgetOne
        nested_widget_two.class.should == NestedWidgetTwo
        deep_nested_widget.class.should == DeepNestedWidget

        # check the internal names of aggregation instances
        widget.global_id.should == 'some_widget'
        nested_widget_one.global_id.should == 'some_widget__nested_one'
        nested_widget_two.global_id.should == 'some_widget__nested_two'
        deep_nested_widget.global_id.should == 'some_widget__nested_two__nested'
      end
    end
  end  
end