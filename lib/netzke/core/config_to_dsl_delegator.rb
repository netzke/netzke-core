module Netzke::Core
  # This module can be included in a component class to allows delegating the configuration options for a component into the level of the component's class.
  # For example:
  #
  #     class SomeComponentBase < Netzke::Base
  #       delegates_to_dsl :title, :html
  #     end
  #
  # This will provide its children with class (DSL) methods +title+ and +html+:
  #
  #     class SomeComponent < SomeComponentBase
  #       title "Some component"
  #       html "HTML set in DSL"
  #     end
  #
  # ... which would be equivalent to:
  #
  #     class SomeComponent < SomeComponentBase
  #       def configure(c)
  #         c.title = "Some component"
  #         c.html = "HTML set in DSL"
  #         super
  #       end
  #     end
  #
  # This may be handy when a frequently-inherited class implements some common options.
  module ConfigToDslDelegator
    extend ActiveSupport::Concern

    included do
      class_attribute :delegated_options
      self.delegated_options = []

      class_attribute :delegated_defaults
      self.delegated_defaults = {}

      delegated_options.each do |property|
        inherited_class.class.send(:define_method, property, lambda { |value|
          self.delegated_defaults = self.delegated_defaults.dup if self.superclass.respond_to?(:delegated_defaults) && self.delegated_defaults == self.superclass.delegated_defaults
          self.delegated_defaults[property.to_sym] = value
        })
      end
    end

    def configure(c)
      c.merge! delegated_defaults
      super
    end

    module ClassMethods
      # Delegates specified configuration options to the class level
      def delegates_to_dsl(*option_names)
        self.delegated_options |= option_names
      end

      def inherited(inherited_class) # :nodoc:
        super

        properties = self.delegated_options
        properties.each do |property|
          inherited_class.class.send(:define_method, property, lambda { |value|
            self.delegated_defaults = self.delegated_defaults.dup if self.superclass.respond_to?(:delegated_defaults) && self.delegated_defaults == self.superclass.delegated_defaults
            self.delegated_defaults[property.to_sym] = value
          })
        end
      end
    end
  end
end
