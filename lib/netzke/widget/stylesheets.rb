module Netzke
  module Widget
    module Stylesheets
      module ClassMethods
        # Returns all extra CSS code (as string) required by this widget's class
        def css_included
          res = ""

          singleton_methods(false).include?("include_css") && include_css.each do |path|
            f = File.new(path)
            res << f.read << "\n"
          end

          res
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