module Netzke
  module Core
    # This class is responsible of assemblage of stylesheet dependencies. It is passed as block parameter to the +client_styles+ DSL method:
    #
    #     class MyComponent < Netzke::Base
    #       client_styles do |c|
    #         c.require :extra_styles
    #       end
    #     end
    class CssConfig

      attr_accessor :required_files

      def initialize(klass)
        @klass = klass
        @required_files = []
      end

      # Use it to specify extra stylesheet files to be loaded for the component.
      #
      # It may accept one or more symbols or strings.
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       client_styles do |c|
      #         c.require :some_styles
      #       end
      #     end
      #
      # This will "require" a stylesheet file +{component_location}/my_component/client/some_styles.css+
      #
      # Strings will be interpreted as full paths to the required JavaScript file:
      #
      #     client_styles do |c|
      #       c.require "#{File.dirname(__FILE__)}/my_component/one.css", "#{File.dirname(__FILE__)}/my_component/two.css"
      #     end
      def require(*args)
        callr = caller.first
        @required_files |= args.map{ |a| a.is_a?(Symbol) ? expand_css_require_path(a, callr) : a }
      end

    private

      def expand_css_require_path(sym, callr)
        %Q(#{callr.split(".rb:").first}/client/#{sym}.css)
      end

    end
  end
end
