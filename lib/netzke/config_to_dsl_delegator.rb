module Netzke
  # This module allows delegating the configuration options for a component into the level of the component's class.
  # As an example, let's take the :title option understood by any Ext.panel.Panel-derived component. Netzke::Base calls:
  #
  #     delegates_to_dsl :title
  #
  # which provides any child class with a DSL method `title` which can be used like this:
  #
  #     class MyComponent < Netzke::Base
  #       title "My cool component"
  #     end
  #
  # This will provide for :title => "My cool component" being a default option for MyComponent's instances.
  #
  # This is very handy when a frequently-inherited class implements some common option. Another example would be the :model option in Basepack::Grid/FormPanel. This way the child class will not need to mess up with the `default_config` method if all it needs is specify that default option.
  module ConfigToDslDelegator
    extend ActiveSupport::Concern

    included do
      class_attribute :delegated_options
      self.delegated_options = []
    end

    module ClassMethods
      # Delegates specified configuration options to the class level. See ConfigToDslDelegator.
      def delegates_to_dsl(*option_names)
        self.delegated_options |= option_names
      end

      def inherited(inherited_class) # :nodoc:
        super

        properties = self.delegated_options
        properties.each do |property|
          inherited_class.class.send(:define_method, property, lambda { |value|
            default_config = self.default_config_attr.dup
            self.default_config_attr = default_config.merge(property.to_sym => value)
          })
        end
      end
    end
  end
end
