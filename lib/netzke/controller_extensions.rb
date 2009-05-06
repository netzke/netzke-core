module Netzke
  module ControllerExtensions
    def self.included(base)
      base.extend ControllerClassMethods
      base.send(:before_filter, :set_session_data)
    end
    
    def set_session_data
      logger.debug "!!! session: #{session.inspect}"
      Netzke::Base.session = session
      session[:user] = current_user if defined?(current_user)

      Netzke::Base.user = session[:user] # for backward compatibility (TODO: eliminate the need for this)
      
      # set netzke_just_logged_in and netzke_just_logged_out states (may be used by Netzke widgets)
      if session[:_netzke_next_request_is_first_after_login]
        session[:netzke_just_logged_in] = true
        session[:_netzke_next_request_is_first_after_login] = false
      else
        session[:netzke_just_logged_in] = false
      end

      if session[:_netzke_next_request_is_first_after_logout]
        session[:netzke_just_logged_out] = true
        session[:_netzke_next_request_is_first_after_logout] = false
      else
        session[:netzke_just_logged_out] = false
      end
    end
    
    def method_missing(method_name)
      if self.class.widget_config_storage == {}
        super
      else
        widget, *action = method_name.to_s.split('__')
        widget = widget.to_sym
        action = !action.empty? && action.join("__").to_sym
      
        # only widget's actions starting with "interface_" are accessible from outside (security)
        if action
          interface_action = action.to_s.index('__') ? action : "interface_#{action}"

          # widget module
          widget_class = "Netzke::#{self.class.widget_config_storage[widget][:widget_class_name]}".constantize

          # instantiate the server part of the widget
          widget_instance = widget_class.new(self.class.widget_config_storage[widget].merge(:controller => self)) # OPTIMIZE: top-level widgets have access to the controller - can we avoid that?
          render :text => widget_instance.send(interface_action, params)
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
      def netzke(name, config={})
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
          
          def #{name}_class_definition_old
            result = ""
            config = controller.class.widget_config_storage[:#{name}]
            @generated_widget_classes ||= []
            # do not duplicate javascript code on the same page
            unless @generated_widget_classes.include?("#{config[:widget_class_name]}")
              @generated_widget_classes << "#{config[:widget_class_name]}"
              result = Netzke::#{config[:widget_class_name]}.js_class_code
            end
            result
          end

          def #{name}_class_definition
            @generated_widget_classes ||= []
            config = controller.class.widget_config_storage[:#{name}]
            widget_instance = Netzke::#{config[:widget_class_name]}.new(config)
            res = widget_instance.js_missing_code(@generated_widget_classes)
            @generated_widget_classes += widget_instance.dependencies
            @generated_widget_classes.uniq!
            res
          end
          
          def #{name}_widget_html
            config = controller.class.widget_config_storage[:#{name}]
            widget_instance = Netzke::Base.instance_by_config(config)
            widget_instance.js_widget_html
          end
          
          def #{name}_widget_render
            config = controller.class.widget_config_storage[:#{name}]
            widget_instance = Netzke::Base.instance_by_config(config)
            widget_instance.js_widget_render
          end
          
        END_EVAL
      
        # add controller action which will render a simple HTML page containing the widget
        define_method("#{name}_test") do
          @widget_name = name
          render :inline => <<-HTML
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<title><%= @widget_name %></title>
	<%= netzke_js_include %>
	<%= netzke_css_include %>
  <script type="text/javascript" charset="utf-8">
    <%= #{name}_class_definition %>
    Ext.onReady(function(){
    	<%= #{name}_widget_instance %>
    	<%= #{name}_widget_render %>
    });
	</script>
</head>
<body>
  <%= #{name}_widget_html %>
</body>
          HTML
        end
      end
    end
  end
  
end