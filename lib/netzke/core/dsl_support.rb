module Netzke
  module Core
    module DslSupport
      extend ActiveSupport::Concern

      module ClassMethods
        # It's the easiest to be explained by an example:
        #
        #     declare_dsl_for :components
        #
        # This creates:
        #
        # 1) DSL method `component` for declaration of child component in a given class, e.g.:
        #
        #     component :simple_panel do |c|
        #       # ...
        #     end
        #
        # Each call to the created `component` method results in an instance method:
        #
        #     def simple_panel_component(c)
        #       # ...
        #     end
        #
        # 2) Instance method `components` that returns a hash of all components configs. This hash is built by passing a new instance of `Netzke::Core::ComponentConfig` to each of the methods described in 1). Presence of `Netzke::Core::ComponentConfig` is assumed.
        #
        # Besides components, this method is being used in Core for DSL for actions.
        def declare_dsl_for(things)
          things = things.to_s
          storage_attribute = :"_declared_#{things}"

          class_attribute storage_attribute
          send("#{storage_attribute}=", [])

          define_dsl_method(things, storage_attribute)
          define_collector_method(things, storage_attribute)
        end


        def define_dsl_method(things, storage_attribute)
          thing = things.singularize

          define_singleton_method thing do |name, &block|
            self.send("#{storage_attribute}=", self.send(storage_attribute) | [name])
            method_name = "#{name}_#{thing}"
            define_method(method_name, &(block || ->(c){c}))
          end
        end

        def define_collector_method(things, storage_attribute)
          thing = things.singularize
          config_class = "Netzke::Core::#{thing.camelcase}Config".constantize

          define_method things do
            # memoization
            return instance_variable_get("@#{things}") if instance_variable_get("@#{things}")

            config_hash = self.class.send(storage_attribute).inject({}) do |out, name|
              c = config_class.new(name, self)
              send("#{name}_#{thing}", c)
              c.set_defaults!
              out.merge(name.to_sym => c.excluded ? {excluded: true} : c)
            end

            instance_variable_set "@#{things}", config_hash
          end
        end
      end
    end
  end
end
