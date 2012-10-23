module Netzke
  module Stylesheets
    extend ActiveSupport::Concern

    included do
      class_attribute :css_included_files
      self.css_included_files = []
    end

    module ClassMethods
      # Configures JS class
      def css_configure &block
        block.call(css_config)
      end

      def css_config
        @_css_config ||= Netzke::Core::CssConfig.new(self)
      end

      # Returns all extra CSS code (as string) required by this component's class
      def css_included
        # Prevent re-including code that was already included by the parent
        # (thus, only include those JS files when include_js was defined in the current class, not in its ancestors)
        ((singleton_methods(false).map(&:to_sym).include?(:include_css) ? include_css : [] ) + css_config.included_files).inject(""){ |r, path| r + File.new(path).read + "\n"}
      end

      # All CSS code needed for this class including the one from the ancestor component
      def css_code(cached = [])
        res = ""

        # include the base-class javascript if doing JS inheritance
        res << superclass.css_code << "\n" if js_config.extending_extjs_component? && !cached.include?(superclass.name)

        res << css_included << "\n"

        res
      end
    end

    def css_missing_code(cached = [])
      code = dependency_classes.inject("") do |r,k|
        cached.include?(k.js_config.xtype) ? r : r + k.css_code(cached)
      end
      code.blank? ? nil : code
    end

  end
end
