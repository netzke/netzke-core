module Netzke
  module ControllerExtensions
    def self.included(base)
      base.extend ControllerClassMethods
    end
    
    def method_missing(method_name)
      if self.class.widget_config_storage == {}
        super
      else
        widget, *action = method_name.to_s.split('__')
        widget = widget.to_sym
        action = !action.empty? && action.join("__").to_sym
      
        # only widget's actions starting with "api_" are accessible from outside (security)
        if action
          api_action = action.to_s.index('__') ? action : "api_#{action}"

          # widget module
          widget_class = "Netzke::#{self.class.widget_config_storage[widget][:widget_class_name]}".constantize

          # instantiate the server part of the widget
          widget_instance = widget_class.new(self.class.widget_config_storage[widget].merge(:controller => self)) # OPTIMIZE: top-level widgets have access to the controller - can we avoid that?
          render :text => widget_instance.send(api_action, params)
        end
      end
    end
    
    module ControllerClassMethods

      # widget_config_storage for all widgets
      def widget_config_storage
        @@widget_config_storage ||= {}
      end
    
      #
      # Use this method to declare a widget in the controller
      #
      def netzke_widget(name, config={})
        # which module is the widget?
        config[:widget_class_name] ||= name.to_s.classify
        config[:name] ||= name
      
        # register the widget config in the storage
        widget_config_storage[name] = config

        # provide widget helpers
        ActionView::Base.module_eval <<-END_EVAL, __FILE__, __LINE__
          def #{name}_widget_instance(config = {})
            # get the global config from the controller's singleton class
            global_config = controller.class.widget_config_storage[:#{name}]

            # when instantiating a client side instance, the configuration may be overwritten 
            # (but the server side will know nothing about it!)
            local_config = global_config.merge(config)

            # instantiate it
            widget_instance = Netzke::#{config[:widget_class_name]}.new(local_config)
          
            # return javascript code for instantiating on the javascript level
            widget_instance.js_widget_instance
          end
          
          def #{name}_class_definition
            config = controller.class.widget_config_storage[:#{name}]
            Netzke::#{config[:widget_class_name]}.new(config).js_missing_code
          end
        END_EVAL
      
        # add controller action which will render a simple HTML page containing the widget
        define_method("#{name}_test") do
          render :inline => %Q(
          <script type="text/javascript" charset="utf-8">
          <%= #{name}_class_definition %>
          Ext.onReady(function(){
          	<%= #{name}_widget_instance %>
          	#{name.to_js}.render("#{name.to_s.split('_').join('-')}");
          })
        	</script>
          <div id="#{name.to_s.split('_').join('-')}"></div>
          ), :layout => "netzke"
        end
      end
    end
  end
  
end