module Netzke
  module Core
    # This class is participating in creation of the client (JavaScript) class. It is passed as block parameter to the `js_configure` DSL method:
    #
    #     class MyComponent < Netzke::Base
    #       js_configure do |c|
    #         c.extend = "Ext.form.Panel"
    #       end
    #     end
    class JsClassConfig
      attr_accessor :included_files, :base_class, :properties, :mixins, :translated_properties

      def initialize(klass)
        @klass = klass
        @included_files = []
        @mixins = []
        @properties = {extend: "Ext.panel.Panel"}
        @translated_properties = []
      end

      # Allows assigning JavaScript prototype properties, including functions:
      #
      #     class MyComponent < Netzke::Base
      #       js_configure do |c|
      #         # this will result in the +title+ property defined on the client class prototype
      #         c.title = "My cool component"
      #
      #         # this will result in the +onButtonPress+ function defined on the client class prototype
      #         c.on_button_press = <<-JS
      #           function(){
      #             // ...
      #           }
      #         JS
      #       end
      #     end
      #
      # An alternative way to define prototype properties is by using "mixins", see {JsClassConfig#mixin}. Note, that, as opposed to using mixins, with +js_configure+ you can assign properties dynamically based on the Ruby class configuration. For example:
      #
      #     class MyComponent < Netzke::Base
      #       class_attribute :title
      #       self.title = "Some default title"
      #       js_configure do |c|
      #         c.title = self.title
      #       end
      #     end
      #
      # Then you can configure your component on a class level like this:
      #
      #     # e.g. in Rails initializers
      #     MyComponent.title = "New title for all MyComponents"
      #
      # Or using a helper method provided by Netzke:
      #
      #     MyComponent.setup do |config|
      #       config.title = "New title for all MyComponents"
      #     end
      def method_missing(name, *args)
        return super unless name =~ /(.+)=$/

        value = args.first
        @properties[$1.to_sym] = value.is_a?(String) && value =~ /^\s*function/ ? ActiveSupport::JSON::Variable.new(value) : value
      end

      # Use it to specify JavaScript files to be loaded *before* this component's JavaScript code. Useful when using external extensions required by this component.
      #
      # It may accept one or more symbols or strings.
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       js_configure do |c|
      #         c.include :some_library
      #       end
      #     end
      #
      # This will "include" a JavaScript file +{component_location}/my_component/javascripts/some_library.js+
      #
      # Strings will be interpreted as full paths to the included JavaScript file:
      #
      #     js_configure do |c|
      #       c.include "#{File.dirname(__FILE__)}/my_component/one.js", "#{File.dirname(__FILE__)}/my_component/two.js"
      #     end
      def include(*args)
        callr = caller.first

        @included_files |= args.map{ |a| a.is_a?(Symbol) ? expand_js_include_path(a, callr) : a }
      end

      # Use it to "mixin" JavaScript objects defined in a separate file. It may accept one or more symbols or strings.
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       js_configure do |c|
      #         c.mixin :some_functionality
      #         #...
      #       end
      #     end
      #
      # This will "mixin" a JavaScript object defined in a file named +{component_location}/my_component/javascripts/some_functionality.js+, which way contain something like this:
      #
      #     {
      #       someProperty: 100,
      #       someMethod: function(params){
      #         // ...
      #       }
      #     }
      #
      # Also accepts a string, which will be interpreted as a full path to the file (useful for sharing mixins between classes).
      # With no parameters, will assume :component_class_name_underscored.
      #
      # Also, see defining JavaScript prototype properties with {JsClassConfig#method_missing}.
      def mixin(*args)
        args << @klass.name.split("::").last.underscore.to_sym if args.empty?
        callr = caller.first
        args.each{ |a| @mixins << (a.is_a?(Symbol) ? File.read(expand_js_include_path(a, callr)) : File.read(a))}
      end

      # Defines the "i18n" config property, that is a translation object for this component, such as:
      #   i18n: {
      #     overwriteConfirm: "Are you sure you want to overwrite preset '{0}'?",
      #     overwriteConfirmTitle: "Overwriting preset",
      #     deleteConfirm: "Are you sure you want to delete preset '{0}'?",
      #     deleteConfirmTitle: "Deleting preset"
      #   }
      #
      # E.g.:
      #
      #   class MyComponent < Netzke::Base
      #     js_configure do |c|
      #       c.translate :overwrite_confirm, :overwrite_confirm_title, :delete_confirm, :delete_confirm_title
      #     end
      #   end
      def translate(*args)
        @translated_properties |= args
      end

    protected

      def expand_js_include_path(sym, callr) # :nodoc:
        %Q(#{callr.split(".rb:").first}/javascripts/#{sym}.js)
      end
    end
  end
end
