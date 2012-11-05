module Netzke
  module Core
    # This class is responsible of creation of the client (JavaScript) class. It is passed as block parameter to the `js_configure` DSL method:
    #
    #     class MyComponent < Netzke::Base
    #       js_configure do |c|
    #         c.extend = "Ext.form.Panel"
    #       end
    #     end
    # TODO: rename to ClientClass
    class ClientClass
      attr_accessor :included_files, :base_class, :properties, :mixins, :translated_properties

      def initialize(klass)
        @klass = klass
        @included_files = []
        @mixins = []
        @properties = {
          extend: extended_class,
          alias: class_alias
        }
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
      # An alternative way to define prototype properties is by using "mixins", see {ClientClass
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

        @included_files |= args.map{ |a| a.is_a?(Symbol) ? expand_include_path(a, callr) : a }
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
      # Also, see defining JavaScript prototype properties with {ClientClass#method_missing}.
      def mixin(*args)
        args << @klass.name.split("::").last.underscore.to_sym if args.empty?
        callr = caller.first
        args.each{ |a| @mixins << (a.is_a?(Symbol) ? File.read(expand_include_path(a, callr)) : File.read(a))}
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

      # The alias, required by Ext.Component, e.g.: widget.helloworld
      def class_alias
        [alias_prefix, xtype].join(".")
      end

      # Builds this component's xtype
      # E.g.: netzkebasepackwindow, netzkebasepackgridpanel
      def xtype
        @klass.name.gsub("::", "").downcase
      end

      # Component's JavaScript class declaration.
      # It gets stored in the JS class cache storage (Netzke.classes) at the client side to be reused at the moment of component instantiation.
      def class_code
        res = []
        # Defining the scope if it isn't known yet
        res << %{Ext.ns("#{scope}");} unless scope == default_scope

        res << (extending_extjs_component? ? class_declaration_new_component : class_declaration_extending_component)

        # Store created class xtype in the cache
        res << %(
Netzke.cache.push('#{xtype}');
)

        res.join("\n")
      end

      # Top level scope which will be used to scope out Netzke classes
      def default_scope
        "Netzke.classes"
      end

      # Returns the scope of this component
      # e.g. "Netzke.classes.Netzke.Basepack"
      def scope
        [default_scope, *@klass.name.split("::")[0..-2]].join(".")
      end

      # Returns the full name of the JavaScript class, including the scopes *and* the common scope, which is 'Netzke.classes'.
      # E.g.: "Netzke.classes.Netzke.Basepack.GridPanel"
      def class_name
        [scope, @klass.name.split("::").last].join(".")
      end

      # Whether we have to inherit from an Ext JS component, or a Netzke component
      def extending_extjs_component?
        @klass.superclass == Netzke::Base
      end

      # Returns all included JavaScript files as a string
      def js_included
        res = ""

        # Prevent re-including code that was already included by the parent
        # (thus, only include those JS files when include_js was defined in the current class, not in its ancestors)
        # FIXME!
        ((@klass.singleton_methods(false).map(&:to_sym).include?(:include_js) ? include_js : []) + included_files).each do |path|
          f = File.new(path)
          res << f.read << "\n"
        end

        res
      end

      # JavaScript code needed for this particulaer class. Includes external JS code and the JS class definition for self.
      def js_code
        [js_included, class_code].join("\n")
      end

    protected

      # Generates declaration of the JS class as direct extension of a Ext component
      def class_declaration_new_component
%(Ext.define('#{class_name}', Netzke.chainApply(Netzke.componentMixin,\n#{mixins_string} #{properties.to_nifty_json}));)
      end

      # Generates declaration of the JS class as extension of another Netzke component
      def class_declaration_extending_component
%(Ext.define('#{class_name}', Netzke.chainApply(#{mixins_string}#{properties.to_nifty_json}));)
      end

      # Alias prefix: 'widget' for components, 'plugin' for plugins
      def alias_prefix
        @klass < Netzke::Plugin ? "plugin" : "widget"
      end

      def mixins_string
        self.mixins.empty? ? "" : %(#{self.mixins.join(", \n")}, )
      end

      # Default extended class
      def extended_class
        extending_extjs_component? ? "Ext.panel.Panel" : @klass.superclass.js_config.class_name
      end

      def expand_include_path(sym, callr) # :nodoc:
        %Q(#{callr.split(".rb:").first}/javascripts/#{sym}.js)
      end
    end
  end
end
