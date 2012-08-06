module Netzke
  module Core
    class CssConfig

      attr_accessor :included_files

      def initialize(klass)
        @klass = klass
        @included_files = []
      end

      def include(*args)
        callr = caller.first
        @included_files |= args.map{ |a| a.is_a?(Symbol) ? expand_css_include_path(a, callr) : a }
      end

    protected

      def expand_css_include_path(sym, callr) # :nodoc:
        %Q(#{callr.split(".rb:").first}/stylesheets/#{sym}.css)
      end

    end
  end
end
