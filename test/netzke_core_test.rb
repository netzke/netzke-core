require 'test_helper'

require 'netzke-core'

# test widgets
module Netzke
  class Widget < Base
    interface :method_one, :method_two
    def initial_aggregatees
      {
        :nested_one => {:widget_class_name => 'NestedWidgetOne'},
        :nested_two => {:widget_class_name => 'NestedWidgetTwo'}
      }
    end
  
    def available_permissions
      %w(read update)
    end
    
    def initial_config
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
        :nested => {:widget_class_name => 'DeepNestedWidget'}
      }
    end
  end

  class DeepNestedWidget < Base
  end

  class JsInheritanceWidget < Base
    def self.js_base_class
      Widget
    end
  end
end

# mocking the User class
class User
  attr_accessor :id
  def initialize(id)
    @id = id
  end
end

class NetzkeCoreTest < ActiveSupport::TestCase
  include Netzke
  
  def setup
    # object = mock()
    # object.stubs(:normalized_value)
    # object.stubs(:normalized_value=)
    # # object.stubs(:save!)
    # NetzkePreference.stubs(:find).returns(object)
    
  end
  
  test "base class loaded" do
    assert_kind_of Netzke::Base, Netzke::Base.new
  end
  
  test "short widget class name" do
    assert_equal 'Widget', Widget.short_widget_class_name
  end
  
  test "interface" do
    widget_class = Widget
    assert_equal [:get_widget, :method_one, :method_two], widget_class.interface_points
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
    assert_equal 'my_widget', widget.id_name
    assert_equal 'my_widget__nested_one', nested_widget_one.id_name
    assert_equal 'my_widget__nested_two', nested_widget_two.id_name
    assert_equal 'my_widget__nested_two__nested', deep_nested_widget.id_name
  end
  
  test "permissions" do
    widget = Widget.new
    assert_equal({:read => true, :update => true}, widget.permissions)

    widget = Widget.new(:prohibit => :all)
    assert_equal({:read => false, :update => false}, widget.permissions)

    widget = Widget.new(:prohibit => :read)
    assert_equal({:read => false, :update => true}, widget.permissions)

    widget = Widget.new(:prohibit => [:read, :update])
    assert_equal({:read => false, :update => false}, widget.permissions)

    widget = Widget.new(:prohibit => :all, :allow => :read)
    assert_equal({:read => true, :update => false}, widget.permissions)

    widget = Widget.new(:prohibit => :all, :allow => [:read, :update])
    assert_equal({:read => true, :update => true}, widget.permissions)
  end
  
  test "default config" do
    widget = Widget.new
    assert_equal({:ext_config => {}, :config_uno => true, :config_dos => false}, widget.config)

    widget = Widget.new(:name => 'widget', :config_uno => false)
    assert_equal({:name => 'widget', :ext_config => {}, :config_uno => false, :config_dos => false}, widget.config)
  end

  test "dependencies calculated based on aggregations" do
    widget = Widget.new
    assert(widget.dependencies.include?('NestedWidgetOne'))
    assert(widget.dependencies.include?('NestedWidgetTwo'))
    assert(!widget.dependencies.include?('DeepNestedWidget'))
  end
  
  # test "dependencies in JS class generators" do
  #   widget = Widget.new
  #   assert(widget.js_missing_code.index("Ext.netzke.cache['NestedWidgetOne']"))
  #   assert(widget.js_missing_code.index("Ext.netzke.cache['NestedWidgetTwo']"))
  #   assert(widget.js_missing_code.index("Ext.netzke.cache['DeepNestedWidget']"))
  #   assert(widget.js_missing_code.index("Ext.netzke.cache['Widget']"))
  # end

  test "dependency classes" do
    widget = Widget.new
    # not testing the order
    assert(%w{DeepNestedWidget NestedWidgetOne NestedWidgetTwo Widget}.inject(true){|r, k| r && widget.dependency_classes.include?(k)})
  end

  test "widget instance by config" do
    widget = Netzke::Base.instance_by_config({:widget_class_name => 'Widget', :name => 'a_widget'})
    assert(Widget, widget.class)
    assert('a_widget', widget.config[:name])
  end

  test "class configuration" do
    assert_equal(NetzkeLayout, Netzke::Base.layout_manager_class)
  end
  
  test "js inheritance" do
    widget = JsInheritanceWidget.new
    assert(widget.js_missing_code.index("Ext.netzke.cache.JsInheritanceWidget"))
    assert(widget.js_missing_code.index("Ext.netzke.cache.Widget"))
  end
  # test "multiuser" do
  #   Netzke::Base.current_user = User.new(1)
  #   Widget.new(:prohibit => :all, :name => 'widget')
  #   
  #   Netzke::Base.current_user = User.new(2)
  #   Widget.new(:prohibit => :read, :name => 'widget')
  #   
  #   Netzke::Base.current_user = User.new(1)
  #   widget = Widget.new(:name => 'widget')
  #   assert_equal({:read => false, :update => false}, widget.permissions)
  # 
  #   Netzke::Base.current_user = User.new(2)
  #   widget = Widget.new(:name => 'widget')
  #   assert_equal({:read => false, :update => true}, widget.permissions)
  #   
  # end
end
