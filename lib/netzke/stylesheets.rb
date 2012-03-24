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
        ((singleton_methods(false).map(&:to_sym).include?(:include_css) ? include_css : [] ) + css_included_files).inject(""){ |r, path| r + File.new(path).read + "\n"}
      end

      # All CSS code needed for this class including the one from the ancestor component
      def css_code(cached = [])
        res = ""

        # include the base-class javascript if doing JS inheritance
        res << superclass.css_code << "\n" if extends_netzke_component? && !cached.include?(superclass.short_component_class_name)

        res << css_included << "\n"

        res
      end

      # Use it to specify stylesheet files to be loaded along with this component.
      # It may accept one or more symbols or strings. Strings will be interpreted as full paths to included files:
      #
      #     css_include "#{File.dirname(__FILE__)}/my_component/one.css", "#{File.dirname(__FILE__)}/my_component/two.css"
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       css_include :some_library
      #       # ...
      #     end
      #
      # This will "include" a stylesheet file +{component_location}/my_component/stylesheets/some_library.js+
      def css_include(*args)
        callr = caller.first

        self.css_included_files += args.map{ |a| a.is_a?(Symbol) ? expand_css_include_path(a, callr) : a }
      end

      protected

        def expand_css_include_path(sym, callr) # :nodoc:
          %Q(#{callr.split(".rb:").first}/stylesheets/#{sym}.css)
        end

    end

    def css_missing_code(cached = [])
      code = dependency_classes.inject("") do |r,k|
        cached.include?(k.js_xtype) ? r : r + k.css_code(cached)
      end
      code.blank? ? nil : code
    end

  end
end
