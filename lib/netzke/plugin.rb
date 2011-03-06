module Netzke
  module Plugin
    extend ActiveSupport::Concern

    PLUGIN_METHOD_NAME = "%s_component"

    module ClassMethods

      # Defines a plugin
      def plugin(name, config = {}, &block)
        component(name, config, &block)
        register_plugin(name)
      end

      # Register a plugin
      def register_plugin(name)
        current_plugins = read_inheritable_attribute(:plugins) || []
        current_plugins << name
        write_inheritable_attribute(:plugins, current_plugins.uniq)
      end

      # Returns registered plugins
      def registered_plugins
        read_inheritable_attribute(:plugins) || []
      end
    end

    def plugins
      self.class.registered_plugins
    end
  end
end