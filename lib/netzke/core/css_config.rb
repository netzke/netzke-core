module Netzke
  module Core
    class CssConfig

      attr_accessor :required_files

      def initialize(klass)
        @klass = klass
        @required_files = []
      end

      def require(*args)
        callr = caller.first
        @required_files |= args.map{ |a| a.is_a?(Symbol) ? expand_css_require_path(a, callr) : a }
      end

    protected

      def expand_css_require_path(sym, callr) # :nodoc:
        %Q(#{callr.split(".rb:").first}_lib/stylesheets/#{sym}.css)
      end

    end
  end
end
