require 'test_helper'
require 'netzke-core'

module Netzke
  class Widget < Base
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

  class NestedWidgetOne < Base
  end

  class NestedWidgetTwo < Base
    def initial_aggregatees
      {
        :nested => {:class_name => 'DeepNestedWidget'}
      }
    end
  end

  class DeepNestedWidget < Base
    def initial_aggregatees
      {
        :nested => {:class_name => "VeryDeepNestedWidget"}
      }
    end
  end
  
  class VeryDeepNestedWidget < Base
  end

  class JsInheritanceWidget < Widget
  end
  
  module ScopedWidgets
    class SomeScopedWidget < Base
    end
  end
  
  class InheritedWidget < Widget
    def self.config
      super.merge({
        :pref_one => -1
      })
    end
  end
end

class NetzkeCoreTest < ActiveSupport::TestCase
  include Netzke
  
  def setup
  end
  
  test "base class loaded" do
    assert_kind_of Netzke::Base, Netzke::Base.new
  end
  
  test "short widget class name" do
    assert_equal 'Widget', Widget.short_widget_class_name
  end
  
  test "api" do
    widget_class = Widget
    assert_equal [:load_aggregatee_with_cache, :method_one, :method_two], widget_class.api_points
  end

  test "aggregatees" do
    widget = Widget.new(:name => 'my_widget')
    
    # instantiate aggregatees
    nested_widget_one = widget.aggregatee_instance(:nested_one)
    nested_widget_two = widget.aggregatee_instance(:nested_two)
    deep_nested_widget = widget.aggregatee_instance(:nested_two__nested)
    
    # check the classes of aggregation instances
    assert_kind_of NestedWidgetOne, nested_widget_one
    assert_kind_of NestedWidgetTwo, nested_widget_two
    assert_kind_of DeepNestedWidget, deep_nested_widget
    
    # check the internal names of aggregation instances
    assert_equal 'my_widget', widget.global_id
    assert_equal 'my_widget__nested_one', nested_widget_one.global_id
    assert_equal 'my_widget__nested_two', nested_widget_two.global_id
    assert_equal 'my_widget__nested_two__nested', deep_nested_widget.global_id
  end
  
  test "global_id_by_reference" do
    w = Widget.new(:name => "a_widget")
    deep_nested_widget = w.aggregatee_instance(:nested_two__nested)
    assert_equal("a_widget__nested_two", deep_nested_widget.global_id_by_reference(:parent))
    assert_equal("a_widget", deep_nested_widget.global_id_by_reference(:parent__parent))
    assert_equal("a_widget__nested_one", deep_nested_widget.global_id_by_reference(:parent__parent__nested_one))
    assert_equal("a_widget__nested_two__nested__nested", deep_nested_widget.global_id_by_reference(:nested))
    assert_equal("a_widget__nested_two__nested__non_existing", deep_nested_widget.global_id_by_reference(:non_existing))
    assert_nil(deep_nested_widget.global_id_by_reference(:parent__parent__parent)) # too far up
  end
  
  test "default config" do
    widget = Widget.new
    assert_equal({:config_uno => true, :config_dos => false}, widget.config)

    widget = Widget.new(:name => 'widget', :config_uno => false)
    assert_equal({:name => 'widget', :config_uno => false, :config_dos => false}, widget.config)
  end

  test "dependencies calculated based on aggregations" do
    widget = Widget.new
    assert(widget.dependencies.include?('NestedWidgetOne'))
    assert(widget.dependencies.include?('NestedWidgetTwo'))
    assert(!widget.dependencies.include?('DeepNestedWidget'))
  end
  
  test "dependency classes" do
    widget = Widget.new
    # not testing the order
    assert(%w{DeepNestedWidget NestedWidgetOne NestedWidgetTwo Widget}.inject(true){|r, k| r && widget.dependency_classes.include?(k)})
  end

  test "widget instance by config" do
    widget = Netzke::Base.instance_by_config({:class_name => 'Widget', :name => 'a_widget'})
    assert_equal(Widget, widget.class)
    assert_equal('a_widget', widget.name)
  end

  test "js inheritance" do
    widget = JsInheritanceWidget.new
    assert(widget.js_missing_code.index("Netzke.classes.JsInheritanceWidget"))
    assert(widget.js_missing_code.index("Netzke.classes.Widget"))
  end

  test "class-level configuration" do
    # predefined defaults
    assert_equal(1, Netzke::Widget.config[:pref_one])
    assert_equal(2, Netzke::Widget.config[:pref_two])
    assert_equal(-1, Netzke::InheritedWidget.config[:pref_one])
    assert_equal(2, Netzke::InheritedWidget.config[:pref_two])

    Netzke::Widget.config[:pref_for_widget] = 1
    Netzke::InheritedWidget.config[:pref_for_widget] = 2
    
    # this is broken in 1.9
    # assert_equal(1, Netzke::Widget.config[:pref_for_widget])
    # assert_equal(2, Netzke::InheritedWidget.config[:pref_for_widget])
    # 
  end

  test "JS class names and scopes" do
    klass = Netzke::NestedWidgetOne
    assert_equal("Netzke.classes", klass.js_full_scope)
    assert_equal("", klass.js_class_name_to_scope(klass.short_widget_class_name))
    
    klass = Netzke::ScopedWidgets::SomeScopedWidget
    assert_equal("Netzke.classes", klass.js_default_scope)
    assert_equal("ScopedWidgets::SomeScopedWidget", klass.short_widget_class_name)
    assert_equal("ScopedWidgets", klass.js_class_name_to_scope(klass.short_widget_class_name))
    assert_equal("Netzke.classes.ScopedWidgets", klass.js_full_scope)
  end

end
