module Netzke
  module Stylesheets
    extend ActiveSupport::Concern
  
    included do
      class_attribute :css_included_files
      self.css_included_files = []
    end
      
    module ClassMethods
      # Returns all extra CSS code (as string) required by this component's class
      def css_included
        # Prevent re-including code that was already included by the parent
        # (thus, only include those JS files when include_js was defined in the current class, not in its ancestors)
        ((singleton_methods(false).include?(:include_css) ? include_css : [] ) + css_included_files).inject(""){ |r, path| r + File.new(path).read + "\n"}
      end

      # All CSS code needed for this class including the one from the ancestor component
      def css_code(cached = [])
        res = ""

        # include the base-class javascript if doing JS inheritance
        res << superclass.css_code << "\n" if extends_netzke_component? && !cached.include?(superclass.short_component_class_name)

        res << css_included << "\n"

        res
      end

      # Definition of CSS files which will be dynamically loaded together with this component
      # e.g. 
      # css_include "#{File.dirname(__FILE__)}/themis_navigation/static.css"
      # or
      # css_include "#{File.dirname(__FILE__)}/themis_navigation/one.css","#{File.dirname(__FILE__)}/themis_navigation/two.css"
      #  This is alternative to defining self.include_css
      def css_include(*args)
        self.css_included_files += args
      end
      
    end
    
    module InstanceMethods
      def css_missing_code(cached = [])
        code = dependency_classes.inject("") do |r,k| 
          cached.include?(k) ? r : r + constantize_class_name(k).css_code(cached)
        end
        code.blank? ? nil : code
      end
      
    end    
  end
end