module Netzke
  module Core
    # This class is responsible of creation of the client (JavaScript) class. It is passed as block parameter to the `client_class` DSL method:
    #
    #     class MyComponent < Netzke::Base
    #       client_class do |c|
    #         c.extend = "Ext.form.Panel"
    #       end
    #     end
    class ClientClassConfig
      attr_accessor :base_class, :properties, :translated_properties, :dir, :requires_as_string

      def initialize(klass, called_from)
        @klass = klass
        @called_from = @dir = called_from
        @requires_as_string = ""
        @explicit_override_paths = []
        @properties = {
          extend: extended_class,
          alias: class_alias,
        }
        @properties[:mixins] = ['Netzke.Core.Component'] if extending_extjs_component?
        @translated_properties = []
      end

      # Allows assigning JavaScript prototype properties, including functions:
      #
      #     class MyComponent < Netzke::Base
      #       client_class do |c|
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
      # An alternative way to define prototype properties is by using "mixins", see {ClientClassConfig#mixin}
      #
      # As attributes are accessible from inside +client_class+:
      #
      #     class MyComponent < Netzke::Base
      #       class_attribute :title
      #       self.title = "Some default title"
      #       client_class do |c|
      #         c.title = self.title
      #       end
      #     end
      #
      # ... you can configure your component on a class level like this:
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
        if name =~ /(.+)=$/
          value = args.first
          @properties[$1.to_sym] = value.is_a?(String) && value =~ /^\s*function/ ? Netzke::Core::JsonLiteral.new(value) : value
        else
          @properties[name.to_sym]
        end
      end

      # Use it to specify JavaScript files to be loaded *before* this component's JavaScript code. Useful when using external extensions required by this component.
      #
      # It may accept one or more symbols or strings.
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       client_class do |c|
      #         c.require :some_library
      #       end
      #     end
      #
      # This will "require" a JavaScript file +{component_location}/my_component/client/some_library.js+
      #
      # Strings will be interpreted as full paths to the required JavaScript file:
      #
      #     client_class do |c|
      #       c.require "#{File.dirname(__FILE__)}/my_component/one.js", "#{File.dirname(__FILE__)}/my_component/two.js"
      #     end
      def require(*refs)
        raise(ArgumentError, "wrong number of arguments (0 for 1 or more)") if refs.empty?
        refs.each do |ref|
          @requires_as_string << require_from_file(normalize_filepath(ref))
        end
      end

      # Use it to "mixin" JavaScript objects defined in a separate file. It may accept one or more symbols or strings.
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       client_class do |c|
      #         c.mixin :some_functionality
      #         #...
      #       end
      #     end
      #
      # This will "mixin" a JavaScript object defined in a file named +{component_location}/my_component/client/some_functionality.js+, which way contain something like this:
      #
      #     {
      #       someProperty: 100,
      #       someMethod: function(params){
      #         // ...
      #       }
      #     }
      #
      # Also accepts a string, which will be interpreted as a full path to the file (useful for sharing mixins between classes).
      # With no parameters, will assume :<component_class_name>.
      #
      # Also, see defining JavaScript prototype properties with {ClientClassConfig#method_missing}.
      def mixin(*refs)
        raise(ArgumentError, "wrong number of arguments (0 for 1 or more)") if refs.empty?

        refs.each do |ref|
          @explicit_override_paths << normalize_filepath(ref)
        end
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
      #     client_class do |c|
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
      # It gets stored in the JS class cache storage (Netzke.cache) at the client side to be reused at the moment of component instantiation.
      def class_code
        res = []
        # Defining the scope if it isn't known yet
        res << %{Ext.ns("#{scope}");} unless scope == default_scope

        res << class_declaration

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
      # e.g. "Netzke.Basepack"
      def scope
        [default_scope, *@klass.name.split("::")[0..-2]].join(".")
      end

      # Returns the full name of the JavaScript class, including the scopes *and* the common scope, which is 'Netzke'.
      # E.g.: "Netzke.Basepack.GridPanel"
      def class_name
        [scope, @klass.name.split("::").last].join(".")
      end

      # Whether we have to inherit from an Ext JS component, or a Netzke component
      def extending_extjs_component?
        @klass.superclass == Netzke::Base
      end

      # JavaScript code needed for this particulaer class. Includes external JS code and the JS class definition for self.
      def code_with_dependencies
        [requires_as_string, class_code].join("\n")
      end

      # Generates declaration of the JS class as direct extension of a Ext component
      def class_declaration
%(Ext.define('#{class_name}', #{properties_as_string});

#{overrides_as_string})
      end

      # Alias prefix: 'widget' for components, 'plugin' for plugins
      def alias_prefix
        @klass < Netzke::Plugin ? "plugin" : "widget"
      end

      def properties_as_string
        [properties.netzke_jsonify.to_json.chop].compact.join(",\n") + "}"
      end

      # Default extended class
      def extended_class
        extending_extjs_component? ? "Ext.panel.Panel" : @klass.superclass.client_class_config.class_name
      end

      def expand_client_code_path(ref)
        "#{@dir}/client/#{ref}.js"
      end

      def override_paths
        return @override_paths if @override_paths

        @override_paths = @explicit_override_paths
        @dir = @called_from
        default_override_path = expand_client_code_path(@dir.split("/").last)
        @override_paths.prepend(default_override_path) if File.exist?(default_override_path)
        @override_paths
      end

      def overrides_as_string
        override_paths.map { |path| mixin_from_file(path) }.join("\n\n")
      end

      private

      def mixin_from_file(path)
        str = File.read(path)
        str.chomp!("\n")
        %(#{class_name}.override(#{str});)
      end

      def require_from_file(path)
        File.new(path).read + "\n"
      end

      def normalize_filepath(ref)
        ref.is_a?(Symbol) ? expand_client_code_path(ref) : ref
      end
    end
  end
end
