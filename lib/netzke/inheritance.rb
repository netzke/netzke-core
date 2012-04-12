module Netzke
  module Inheritance
    extend ActiveSupport::Concern

    module ClassMethods
      # All ancestor classes in the Netzke class hierarchy (i.e. up to Netzke::Base)
      def class_ancestors
        if self == Netzke::Base
          []
        else
          superclass.class_ancestors + [self]
        end
      end

      # Same as +class_attribute+ returning a hash, but returns empty hash when it's equal to superclass's
      def clean_class_attribute_hash(attr_name)
        res = self.send(attr_name)
        # We don't want here any values from the superclass (which is the consequence of using class attributes).
        res == self.superclass.send(attr_name) ? {} : res
      end

      # Same as +class_attribute+ returning an array, but returns empty array when it's equal to superclass's
      def clean_class_attribute_array(attr_name)
        res = self.send(attr_name) || []
        # We don't want here any values from the superclass (which is the consequence of using class attributes).
        res == self.superclass.send(attr_name) ? [] : res
      end

    end
  end
end
