require 'active_support/core_ext/class/inheritable_attributes'

module Netzke
  module Component
    module Composition
      module ClassMethods
      end
      
      module InstanceMethods
        def initial_components
          {}
        end

        def components
          # detect_components_in_config if @components.nil?
          @components
          # @components ||= initial_components.merge(initial_late_components.each_pair{|k,v| v.merge!(:lazy_loading => true)})
        end

        def non_late_components
          components.reject{|k,v| v[:lazy_loading]}
        end

        def add_component(aggr)
          components.merge!(aggr)
        end

        def remove_component(aggr)
          if config[:persistent_config]
            persistent_config_manager_class.delete_all_for_component("#{global_id}__#{aggr}")
          end
          components[aggr] = nil
        end

        # The difference between components and late components is the following: the former gets instantiated together with its composite and is normally *instantly* visible as a part of it (for example, the component in the initially expanded panel in an Accordion). A late component doesn't get instantiated along with its composite. Until it gets requested from the server, it doesn't take any part in its composite's life. An example of late component could be a component that is loaded dynamically into a previously collapsed panel of an Accordion, or a preferences window (late component) for a component (composite) that only gets shown when user wants to edit component's preferences.
        def initial_late_components
          {}
        end

        def add_late_component(aggr)
          components.merge!(aggr.merge(:lazy_loading => true))
        end

        # called when the method_missing tries to processes a non-existing component
        def component_missing(aggr)
          flash :error => "Unknown component #{aggr} for component #{name}"
          {:feedback => @flash}.to_nifty_json
        end

        # recursively instantiates an component based on its "path": e.g. if we have an component :aggr1 which in its turn has an component :aggr10, the path to the latter would be "aggr1__aggr10"
        # TODO: introduce memoization
        def component_instance(name, strong_config = {})
          @cached_component_instances ||= {}
          @cached_component_instances[name] ||= begin
            composite = self
            name.to_s.split('__').each do |aggr|
              aggr = aggr.to_sym
              component_config = composite.components[aggr]
              raise ArgumentError, "No component '#{aggr}' defined for component '#{composite.global_id}'" if component_config.nil?
              short_component_class_name = component_config[:class_name]
              raise ArgumentError, "No class_name specified for component #{aggr} of #{composite.global_id}" if short_component_class_name.nil?
              component_class = "Netzke::#{short_component_class_name}".constantize

              conf = weak_children_config.
                deep_merge(component_config).
                deep_merge(strong_config). # we may want to reconfigure the component at the moment of instantiation
                merge(:name => aggr)

              composite = component_class.new(conf, composite) # params: config, parent
              # composite.weak_children_config = weak_children_config
              # composite.strong_children_config = strong_children_config
            end
            composite
          end
        end
        
        # API: provides what is necessary for the browser to render a component.
        # <tt>params</tt> should contain: 
        # * <tt>:cache</tt> - an array of component classes cached at the browser
        # * <tt>:id</tt> - reference to the component
        # * <tt>:container</tt> - Ext id of the container where in which the component will be rendered
        def load_component_with_cache(params)
          cache = params[:cache].gsub(".", "::").split(",") # array of cached class names (in Ruby)
          relative_component_id = params.delete(:id).underscore.to_sym
          component = components[relative_component_id] && component_instance(relative_component_id)

          if component
            # inform the component that it's being loaded
            component.before_load

            [{
              :js => component.js_missing_code(cache), 
              :css => component.css_missing_code(cache)
            }, {
              :render_component_in_container => { # TODO: rename it
                :container => params[:container], 
                :config => component.js_config
              }
            }, {
              :component_loaded => {
                :id => relative_component_id
              }
            }]
          else
            {:feedback => "Couldn't load component '#{relative_component_id}'"}
          end
        end
        
        def dependency_classes
          res = []
          non_late_components.keys.each do |aggr|
            res += component_instance(aggr).dependency_classes
          end
          res << short_component_class_name
          res.uniq
        end

        ## Dependencies
        def dependencies
          @dependencies ||= begin
            non_late_components_component_classes = non_late_components.values.map{|v| v[:class_name]}
            (initial_dependencies + non_late_components_component_classes << self.class.short_component_class_name).uniq
          end
        end

        # override this method if you need some extra dependencies, which are not the components
        def initial_dependencies
          []
        end

        # Component's js config used when embedding components as Container's items 
        # (see some_composite.rb for an example)
        def js_component(name, config = {})
          config.merge(:component => name)
        end

        # Returns global id of a component in the hierarchy, based on passed reference that follows
        # the double-underscore notation. Referring to "parent" is allowed. If going to far up the hierarchy will 
        # result in <tt>nil</tt>, while referring to a non-existent component will simply provide an erroneous ID.
        # Example:
        # <tt>parent__parent__child__subchild</tt> will traverse the hierarchy 2 levels up, then going down to "child",
        # and further to "subchild". If such a component exists in the hierarchy, its global id will be returned, otherwise
        # <tt>nil</tt> will be returned.
        def global_id_by_reference(ref)
          ref = ref.to_s
          return parent && parent.global_id if ref == "parent"
          substr = ref.sub(/^parent__/, "")
          if substr == ref # there's no "parent__" in the beginning
            return global_id + "__" + ref
          else
            return parent.global_id_by_reference(substr)
          end
        end

        # Method dispatcher - instantiates an component and calls the method on it
        # E.g.: 
        #   users__center__get_data
        #     instantiates component "users", and calls "center__get_data" on it
        #   books__move_column
        #     instantiates component "books", and calls "api_move_column" on it
        def method_missing(method_name, params = {})
          component, *action = method_name.to_s.split('__')
          component = component.to_sym
          action = !action.empty? && action.join("__").to_sym

          if action
            if components[component]
              # only actions starting with "api_" are accessible
              api_action = action.to_s.index('__') ? action : "api_#{action}"
              component_instance(component).send(api_action, params)
            else
              component_missing(component)
            end
          else
            super
          end
        end
        
        private
          
          # If :items are specified, recursively detect components in them, and build @js_items - normalized items config that will have component configs
          # replaced by references to corresponding components.
          def process_items_config
            @js_items = config[:items]
            @component_index = 0 # for automatic naming those components that have no name specified
            @js_items && detect_components_in_items(@js_items)
          end

          def detect_components_in_items(items)
            items.each_with_index do |item, i|
              if item.is_a?(Hash) && item[:class_name]
                aggr_name = item[:name] || :"#{item[:class_name].underscore.split("/").last}#{@component_index}"; @component_index += 1
                @components[aggr_name.to_sym] = item
                items[i] = js_component(aggr_name)
              elsif item.is_a?(Hash)
                item[:items].is_a?(Array) && detect_components_in_items(item[:items])
              end
            end
          end

      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.api :load_component_with_cache # every component gets this api
      end
    end
  end
end
