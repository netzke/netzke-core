module Netzke
  module Widget
    module Aggregation
      module ClassMethods
        # Declare connection points between client side of a widget and its server side. For example:
        #
        #     api :reset_data
        # 
        # will provide JavaScript side with a method <tt>resetData</tt> that will result in a call to Ruby 
        # method <tt>reset_data</tt>, e.g.:
        # 
        #     this.resetData({hard:true});
        # 
        # See netzke-basepack's GridPanel for an example.
        def api(*api_points)
          apip = read_inheritable_attribute(:api_points) || []
          api_points.each{|p| apip << p}
          write_inheritable_attribute(:api_points, apip)

          # It may be needed later for security
          api_points.each do |apip|
            module_eval <<-END, __FILE__, __LINE__
            def api_#{apip}(*args)
              before_api_call_result = defined?(before_api_call) && before_api_call('#{apip}', *args) || {}
              (before_api_call_result.empty? ? #{apip}(*args) : before_api_call_result).to_nifty_json
            end
            END
          end
        end

        # Array of API-points specified with <tt>Netzke::Base.api</tt> method
        def api_points
          read_inheritable_attribute(:api_points)
        end

      end
      
      module InstanceMethods
        def initial_aggregatees
          {}
        end

        def aggregatees
          @aggregatees ||= initial_aggregatees.merge(initial_late_aggregatees.each_pair{|k,v| v.merge!(:late_aggregation => true)})
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
          aggregator = self
          name.to_s.split('__').each do |aggr|
            aggr = aggr.to_sym
            aggregatee_config = aggregator.aggregatees[aggr]
            raise ArgumentError, "No aggregatee '#{aggr}' defined for widget '#{aggregator.global_id}'" if aggregatee_config.nil?
            ::ActiveSupport::Deprecation.warn("widget_class_name option is deprecated. Use class_name instead", caller) if aggregatee_config[:widget_class_name]
            short_widget_class_name = aggregatee_config[:class_name] || aggregatee_config[:widget_class_name]
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

      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.api :load_aggregatee_with_cache # every widget gets this api
      end
    end
  end
end