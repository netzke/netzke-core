module Netzke
  module Core
    module Inheritance
      extend ActiveSupport::Concern
      module ClassMethods
        attr_accessor :called_from

        # Ancestor classes in the Netzke class hierarchy up to (and excluding) +Netzke::Base+, including self; in comparison to Ruby's own Class.ancestors, the order is reversed.
        def netzke_ancestors
          if self == Netzke::Base
            []
          else
            superclass.netzke_ancestors + [self]
          end
        end

        # Keep track of component's file. Inspired by Rails railties code.
        def inherited(base)
          base.called_from = begin
            cllr = if Kernel.respond_to?(:caller_locations)
              location = caller_locations.first
              location.absolute_path || location.path
            else
              caller.first.sub(/:\d+.*/, '')
            end

            cllr[0..-4]
          end
        end
      end
    end
  end
end
