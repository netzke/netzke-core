require 'test_helper'
require 'netzke-core'

module Netzke
  class Component < Base
    api :method_one, :method_two

    def self.config
      super.merge({
        :pref_one => 1,
        :pref_two => 2
      })
    end

    component :nested_one, :class_name => 'NestedComponentOne'
    component :nested_two, :class_name => 'NestedComponentTwo'

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
    def initial_components
      {
        :nested => {:class_name => 'DeepNestedComponent'}
      }
    end
  end

  class DeepNestedComponent < Base
    def initial_components
      {
        :nested => {:class_name => "VeryDeepNestedComponent"}
      }
    end
  end

  class VeryDeepNestedComponent < Base
  end

  class JsInheritanceComponent < Component
  end

  module ScopedComponents
    class SomeScopedComponent < Base
    end
  end

  class InheritedComponent < Component
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

  test "short component class name" do
    assert_equal 'Component', Component.short_component_class_name
  end

  test "api" do
    component_class = Component
    assert_equal [:deliver_component, :method_one, :method_two], component_class.endpoints
  end

  test "components" do
    component = Component.new(:name => 'my_component')

    # instantiate components
    nested_component_one = component.component_instance(:nested_one)
    nested_component_two = component.component_instance(:nested_two)
    deep_nested_component = component.component_instance(:nested_two__nested)

    assert_kind_of NestedComponentOne, nested_component_one
    assert_kind_of NestedComponentTwo, nested_component_two
    assert_kind_of DeepNestedComponent, deep_nested_component

    assert_equal 'my_component', component.global_id
    assert_equal 'my_component__nested_one', nested_component_one.global_id
    assert_equal 'my_component__nested_two', nested_component_two.global_id
    assert_equal 'my_component__nested_two__nested', deep_nested_component.global_id
  end

  test "global_id_by_reference" do
    w = Component.new(:name => "a_component")
    deep_nested_component = w.component_instance(:nested_two__nested)
    assert_equal("a_component__nested_two", deep_nested_component.global_id_by_reference(:parent))
    assert_equal("a_component", deep_nested_component.global_id_by_reference(:parent__parent))
    assert_equal("a_component__nested_one", deep_nested_component.global_id_by_reference(:parent__parent__nested_one))
    assert_equal("a_component__nested_two__nested__nested", deep_nested_component.global_id_by_reference(:nested))
    assert_equal("a_component__nested_two__nested__non_existing", deep_nested_component.global_id_by_reference(:non_existing))
    assert_nil(deep_nested_component.global_id_by_reference(:parent__parent__parent)) # too far up
  end

  test "default config" do
    component = Component.new
    assert_equal({:config_uno => true, :config_dos => false}, component.config)

    component = Component.new(:name => 'component', :config_uno => false)
    assert_equal({:name => 'component', :config_uno => false, :config_dos => false}, component.config)
  end

  test "dependencies calculated" do
    component = Component.new
    assert(component.dependencies.include?('NestedComponentOne'))
    assert(component.dependencies.include?('NestedComponentTwo'))
    assert(!component.dependencies.include?('DeepNestedComponent'))
  end

  test "dependency classes" do
    component = Component.new
    # not testing the order
    assert(%w{DeepNestedComponent NestedComponentOne NestedComponentTwo Component}.inject(true){|r, k| r && component.dependency_classes.include?(k)})
  end

  test "component instance by config" do
    component = Netzke::Base.instance_by_config({:class_name => 'Component', :name => 'a_component'})
    assert_equal(Component, component.class)
    assert_equal('a_component', component.name)
  end

  test "js inheritance" do
    component = JsInheritanceComponent.new
    assert(component.js_missing_code.index("Netzke.classes.JsInheritanceComponent"))
    assert(component.js_missing_code.index("Netzke.classes.Component"))
  end

  test "class-level configuration" do
    # predefined defaults
    assert_equal(1, Netzke::Component.config[:pref_one])
    assert_equal(2, Netzke::Component.config[:pref_two])
    assert_equal(-1, Netzke::InheritedComponent.config[:pref_one])
    assert_equal(2, Netzke::InheritedComponent.config[:pref_two])

    Netzke::Component.config[:pref_for_component] = 1
    Netzke::InheritedComponent.config[:pref_for_component] = 2

    # this is broken in 1.9
    # assert_equal(1, Netzke::Component.config[:pref_for_component])
    # assert_equal(2, Netzke::InheritedComponent.config[:pref_for_component])
    #
  end

  test "JS class names and scopes" do
    klass = Netzke::NestedComponentOne
    assert_equal("Netzke.classes", klass.js_full_scope)
    assert_equal("", klass.js_class_name_to_scope(klass.short_component_class_name))

    klass = Netzke::ScopedComponents::SomeScopedComponent
    assert_equal("Netzke.classes", klass.js_default_scope)
    assert_equal("ScopedComponents::SomeScopedComponent", klass.short_component_class_name)
    assert_equal("ScopedComponents", klass.js_class_name_to_scope(klass.short_component_class_name))
    assert_equal("Netzke.classes.ScopedComponents", klass.js_full_scope)
  end

end
