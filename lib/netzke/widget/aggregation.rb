require 'active_support/core_ext/class/inheritable_attributes'

module Netzke
  module Widget
    module Aggregation
      module ClassMethods
      end
      
      module InstanceMethods
        def initial_aggregatees
          {}
        end

        def aggregatees
          # detect_aggregatees_in_config if @aggregatees.nil?
          @aggregatees
          # @aggregatees ||= initial_aggregatees.merge(initial_late_aggregatees.each_pair{|k,v| v.merge!(:late_aggregation => true)})
        end

        def non_late_aggregatees
          aggregatees.reject{|k,v| v[:late_aggregation]}
        end

        def add_aggregatee(aggr)
          aggregatees.merge!(aggr)
        end

        def remove_aggregatee(aggr)
          if config[:persistent_config]
            persistent_config_manager_class.delete_all_for_widget("#{global_id}__#{aggr}")
          end
          aggregatees[aggr] = nil
        end

        # The difference between aggregatees and late aggregatees is the following: the former gets instantiated together with its aggregator and is normally *instantly* visible as a part of it (for example, the widget in the initially expanded panel in an Accordion). A late aggregatee doesn't get instantiated along with its aggregator. Until it gets requested from the server, it doesn't take any part in its aggregator's life. An example of late aggregatee could be a widget that is loaded dynamically into a previously collapsed panel of an Accordion, or a preferences window (late aggregatee) for a widget (aggregator) that only gets shown when user wants to edit widget's preferences.
        def initial_late_aggregatees
          {}
        end

        def add_late_aggregatee(aggr)
          aggregatees.merge!(aggr.merge(:late_aggregation => true))
        end

        # called when the method_missing tries to processes a non-existing aggregatee
        def aggregatee_missing(aggr)
          flash :error => "Unknown aggregatee #{aggr} for widget #{name}"
          {:feedback => @flash}.to_nifty_json
        end

        # recursively instantiates an aggregatee based on its "path": e.g. if we have an aggregatee :aggr1 which in its turn has an aggregatee :aggr10, the path to the latter would be "aggr1__aggr10"
        # TODO: introduce memoization
        def aggregatee_instance(name, strong_config = {})
          @cached_aggregatee_instances ||= {}
          @cached_aggregatee_instances[name] ||= begin
            aggregator = self
            name.to_s.split('__').each do |aggr|
              aggr = aggr.to_sym
              aggregatee_config = aggregator.aggregatees[aggr]
              raise ArgumentError, "No aggregatee '#{aggr}' defined for widget '#{aggregator.global_id}'" if aggregatee_config.nil?
              short_widget_class_name = aggregatee_config[:class_name]
              raise ArgumentError, "No class_name specified for aggregatee #{aggr} of #{aggregator.global_id}" if short_widget_class_name.nil?
              widget_class = "Netzke::#{short_widget_class_name}".constantize

              conf = weak_children_config.
                deep_merge(aggregatee_config).
                deep_merge(strong_config). # we may want to reconfigure the aggregatee at the moment of instantiation
                merge(:name => aggr)

              aggregator = widget_class.new(conf, aggregator) # params: config, parent
              # aggregator.weak_children_config = weak_children_config
              # aggregator.strong_children_config = strong_children_config
            end
            aggregator
          end
        end
        
        # API: provides what is necessary for the browser to render a widget.
        # <tt>params</tt> should contain: 
        # * <tt>:cache</tt> - an array of widget classes cached at the browser
        # * <tt>:id</tt> - reference to the aggregatee
        # * <tt>:container</tt> - Ext id of the container where in which the aggregatee will be rendered
        def load_aggregatee_with_cache(params)
          cache = params[:cache].gsub(".", "::").split(",") # array of cached class names (in Ruby)
          relative_widget_id = params.delete(:id).underscore.to_sym
          widget = aggregatees[relative_widget_id] && aggregatee_instance(relative_widget_id)

          if widget
            # inform the widget that it's being loaded
            widget.before_load

            [{
              :js => widget.js_missing_code(cache), 
              :css => widget.css_missing_code(cache)
            }, {
              :render_widget_in_container => { # TODO: rename it
                :container => params[:container], 
                :config => widget.js_config
              }
            }, {
              :widget_loaded => {
                :id => relative_widget_id
              }
            }]
          else
            {:feedback => "Couldn't load aggregatee '#{relative_widget_id}'"}
          end
        end
        
        def dependency_classes
          res = []
          non_late_aggregatees.keys.each do |aggr|
            res += aggregatee_instance(aggr).dependency_classes
          end
          res << short_widget_class_name
          res.uniq
        end

        ## Dependencies
        def dependencies
          @dependencies ||= begin
            non_late_aggregatees_widget_classes = non_late_aggregatees.values.map{|v| v[:class_name]}
            (initial_dependencies + non_late_aggregatees_widget_classes << self.class.short_widget_class_name).uniq
          end
        end

        # override this method if you need some extra dependencies, which are not the aggregatees
        def initial_dependencies
          []
        end

        # Aggregatee's js config used when embedding aggregatees as Container's items 
        # (see static_aggregator.rb for an example)
        def js_aggregatee(name, config = {})
          config.merge(:aggregatee => name)
        end

        # Returns global id of a widget in the hierarchy, based on passed reference that follows
        # the double-underscore notation. Referring to "parent" is allowed. If going to far up the hierarchy will 
        # result in <tt>nil</tt>, while referring to a non-existent aggregatee will simply provide an erroneous ID.
        # Example:
        # <tt>parent__parent__child__subchild</tt> will traverse the hierarchy 2 levels up, then going down to "child",
        # and further to "subchild". If such a widget exists in the hierarchy, its global id will be returned, otherwise
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

        # Method dispatcher - instantiates an aggregatee and calls the method on it
        # E.g.: 
        #   users__center__get_data
        #     instantiates aggregatee "users", and calls "center__get_data" on it
        #   books__move_column
        #     instantiates aggregatee "books", and calls "api_move_column" on it
        def method_missing(method_name, params = {})
          widget, *action = method_name.to_s.split('__')
          widget = widget.to_sym
          action = !action.empty? && action.join("__").to_sym

          if action
            if aggregatees[widget]
              # only actions starting with "api_" are accessible
              api_action = action.to_s.index('__') ? action : "api_#{action}"
              aggregatee_instance(widget).send(api_action, params)
            else
              aggregatee_missing(widget)
            end
          else
            super
          end
        end
        
        private
          
          # If :items are specified, recursively detect aggregatees in them, and build @js_items - normalized items config that will have aggregatee configs
          # replaced by references to corresponding aggregatees.
          def process_items_config
            @js_items = config[:items]
            @aggregatee_index = 0 # for automatic naming those aggregatees that have no name specified
            @js_items && detect_aggregatees_in_items(@js_items)
          end

          def detect_aggregatees_in_hash(hsh)
            hsh[:items] && detect_aggregatees_in_items(hsh[:items])
          end

          def detect_aggregatees_in_items(items)
            items.each_with_index do |item, i|
              if item[:class_name]
                aggr_name = item[:name] || :"aggregatee#{@aggregatee_index}"; @aggregatee_index += 1
                @aggregatees[aggr_name] = item
                items[i] = js_aggregatee(aggr_name)
              else
                detect_aggregatees_in_hash(item)
              end
            end
          end

      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.api :load_aggregatee_with_cache # every widget gets this api
      end
    end
  end
end
