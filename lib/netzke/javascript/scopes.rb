module Netzke
  module Javascript
    module Scopes
      extend ActiveSupport::Concern

      module ClassMethods
        # Given class name, e.g. GridPanelLib::Components::RecordFormWindow,
        # returns its scope: "Components.RecordFormWindow"
        def js_class_name_to_scope(name)
          name.split("::")[0..-2].join(".")
        end

        # Top level scope which will be used to scope out Netzke classes
        def js_default_scope
          "Netzke.classes"
        end

        # Scope of this component without default scope
        # e.g.: GridPanelLib.Components
        def js_scope
          js_class_name_to_scope(short_component_class_name)
        end

        # Returns the scope of this component
        # e.g. "Netzke.classes.GridPanelLib"
        def js_full_scope
          js_scope.empty? ? js_default_scope : [js_default_scope, js_scope].join(".")
        end

        # Returns the full name of the JavaScript class, including the scopes *and* the common scope, which is
        # Netzke.classes.
        # E.g.: "Netzke.classes.Netzke.GridPanelLib.RecordFormWindow"
        def js_full_class_name
          [js_full_scope, short_component_class_name.split("::").last].join(".")
        end
      end
    end
  end
end
