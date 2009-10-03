module Netzke
  module ControllerExtensions
    def self.included(base)
      base.extend ControllerClassMethods
      base.send(:before_filter, :set_session_data)
    end
    
    def set_session_data
      Netzke::Base.session = session
      session[:netzke_user_id] = defined?(current_user) ? current_user.try(:id) : nil

      Netzke::Base.user = defined?(current_user) ? current_user : nil # for backward compatibility (TODO: eliminate the need for this)
      
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
      
        # only widget's actions starting with "api_" are accessible from outside (security)
        if action
          api_action = action.to_s.index('__') ? action : "api_#{action}"

          # widget module
          widget_class = "Netzke::#{self.class.widget_config_storage[widget][:widget_class_name]}".constantize

          # instantiate the server part of the widget
          widget_instance = widget_class.new(self.class.widget_config_storage[widget])
          # (OLD VERSION)
          # widget_instance = widget_class.new(self.class.widget_config_storage[widget].merge(:controller => self)) # OPTIMIZE: top-level widgets have access to the controller - can we avoid that?
          
          render :text => widget_instance.send(api_action, params)
        end
      end
    end
    
    module ControllerClassMethods

      # widget_config_storage for all widgets
      def widget_config_storage
        @@widget_config_storage ||= {}
        @@widget_config_storage[self.name] ||= {} # specific for controller
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
          def #{name}_server_instance(config = {})
            default_config = controller.class.widget_config_storage[:#{name}]
            if config.empty?
              # only cache when the config is empty (which means that config specified in controller is used)
              @widget_instance_cache ||= {}
              @widget_instance_cache[:#{name}] ||= Netzke::Base.instance_by_config(default_config)
            else
              # if helper is called with parameters - always return a fresh instance of widget, no caching
              Netzke::Base.instance_by_config(default_config.deep_merge(config))
            end
          end
        
          def #{name}_widget_instance(config = {})
            #{name}_server_instance(config).js_widget_instance
          end
          
          def #{name}_class_definition
            @generated_widget_classes ||= []
            res = #{name}_server_instance.js_missing_code(@generated_widget_classes)
            
            # prevent duplication of javascript when multiple homogeneous widgets are on the same page
            @generated_widget_classes += #{name}_server_instance.dependencies
            @generated_widget_classes.uniq!
            res
          end
          
          def #{name}_widget_html
            #{name}_server_instance.js_widget_html
          end
          
          def #{name}_widget_render
            #{name}_server_instance.js_widget_render
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