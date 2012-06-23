module Netzke
  module Core
    # TODO: rename to JsClassConfig
    # TODO: specs
    class JavascriptClassConfig
      attr_accessor :included_files, :base_class, :properties, :mixins

      def initialize(klass)
        @klass = klass
        @included_files = []
        @mixins = []
        @properties = {extend: "Ext.panel.Panel"}
      end

      # def property name, value
      #   @properties[name.to_sym] = value
      # end

      def method_missing(name, *args)
        return super unless name =~ /(.+)=$/

        value = args.first
        @properties[$1.to_sym] = value.is_a?(String) && value =~ /^\s*function/ ? ActiveSupport::JSON::Variable.new(value) : value
      end

      # Use it to specify JS files to be loaded before this component's JS code. Useful when using external extensions required by this component.
      # It may accept one or more symbols or strings. Strings will be interpreted as full paths to included JS file:
      #
      #     js_include "#{File.dirname(__FILE__)}/my_component/one.js","#{File.dirname(__FILE__)}/my_component/two.js"
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       js_include :some_library
      #       # ...
      #     end
      #
      # This will "include" a JavaScript file +{component_location}/my_component/javascripts/some_library.js+
      def include(*args)
        callr = caller.first

        @included_files |= args.map{ |a| a.is_a?(Symbol) ? expand_js_include_path(a, callr) : a }
      end

      # Use it to "mixin" JavaScript objects defined in a separate file.
      #
      # You do not _have_ to use +js_method+ or +js_properties+ if those methods or properties are not supposed to be changed _dynamically_ (by means of configuring the component on the class level). Instead, you may "mixin" a JavaScript object defined in the JavaScript file named following a certain convention. This way static JavaScript code will rest in a corresponding .js file, not in the Ruby class. E.g.:
      #
      #     class MyComponent < Netzke::Base
      #       js_mixin :some_functionality
      #       #...
      #     end
      #
      # This will "mixin" a JavaScript object defined in a file called +{component_location}/my_component/javascripts/some_functionality.js+, which way contain something like this:
      #
      #     {
      #       someProperty: 100,
      #
      #       someMethod: function(params){
      #         // ...
      #       }
      #     }
      #
      # Also accepts a string, which will be interpreted as a full path to the file (useful for sharing mixins between classes).
      # With no parameters, will assume :component_class_name_underscored.
      def mixin(*args)
        args << @klass.name.split("::").last.underscore.to_sym if args.empty?
        callr = caller.first
        args.each{ |a| @mixins << (a.is_a?(Symbol) ? File.read(expand_js_include_path(a, callr)) : File.read(a))}
      end

    private

      def expand_js_include_path(sym, callr) # :nodoc:
        %Q(#{callr.split(".rb:").first}/javascripts/#{sym}.js)
      end

    end
  end
end
