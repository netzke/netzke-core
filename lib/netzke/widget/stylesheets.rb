module Netzke
  module Widget
    module Stylesheets
      module ClassMethods
        # Returns all extra CSS code (as string) required by this widget's class
        def css_included
          # Prevent re-including code that was already included by the parent
          # (thus, only include those JS files when include_js was defined in the current class, not in its ancestors)
          singleton_methods(false).include?(:include_css) ? include_css.inject(""){ |r, path| r + File.new(path).read + "\n"} : ""
        end

        # All CSS code needed for this class including the one from the ancestor widget
        def css_code(cached = [])
          res = ""

          # include the base-class javascript if doing JS inheritance
          res << superclass.css_code << "\n" if js_inheritance? && !cached.include?(superclass.short_widget_class_name)

          res << css_included << "\n"

          res
        end
        
      end
      
      module InstanceMethods
        def css_missing_code(cached = [])
          code = dependency_classes.inject("") do |r,k| 
            cached.include?(k) ? r : r + "Netzke::#{k}".constantize.css_code(cached)
          end
          code.blank? ? nil : code
        end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end