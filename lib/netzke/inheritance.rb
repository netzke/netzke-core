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

      # Same as +read_inheritable_attribute+ returning a hash, but returns empty hash when it's equal to superclass's
      def read_clean_inheritable_hash(attr_name)
        res = read_inheritable_attribute(attr_name) || {}
        # We don't want here any values from the superclass (which is the consequence of using inheritable attributes).
        res == self.superclass.read_inheritable_attribute(attr_name) ? {} : res
      end

      # Same as +read_inheritable_attribute+ returning a hash, but returns empty hash when it's equal to superclass's
      def read_clean_inheritable_array(attr_name)
        res = read_inheritable_attribute(attr_name) || []
        # We don't want here any values from the superclass (which is the consequence of using inheritable attributes).
        res == self.superclass.read_inheritable_attribute(attr_name) ? [] : res
      end

    end
  end
end
