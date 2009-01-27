require 'json'

module Netzke
  # 
  # Configuration:
  # * Define NETZKE_BOOT_CONFIG in environment.rb to specify which Netzke functionality should be disabled 
  # to reduce the size of /netzke/netzke.[js|css]. Those Netzke gems that use additional JS/CSS-code 
  # should be aware of this constant.
  #
  class Base
    # Client-side code (generates JS-class of the widget)
    include Netzke::JsClassBuilder

    module ClassMethods

      # Global Netzke::Base configuration
      def config
        set_default_config({
          :javascripts               => [],
          :css                       => [],
          :layout_manager            => "NetzkeLayout",
          :persistent_config_manager => "NetzkePreference"
        })
      end

      def short_widget_class_name
        name.split("::").last
      end

      def user
        @@user ||= nil
      end

      def user=(user)
        @@user = user

        # also set up the managers
        persistent_config_manager_class && persistent_config_manager_class.user = user
        layout_manager_class && layout_manager_class.user = user
      end

      #
      # Use this class method to declare connection points between client side of a widget and its server side. A method in a widget class with the same name will be (magically) called by the client side of the widget. See Grid widget for an example
      #
      def interface(*interface_points)
        interfacep = read_inheritable_attribute(:interface_points) || []
        interface_points.each{|p| interfacep << p}
        write_inheritable_attribute(:interface_points, interfacep)

        interface_points.each do |interfacep|
          module_eval <<-END, __FILE__, __LINE__
          def interface_#{interfacep}(*args)
            #{interfacep}(*args).to_js
          end
          # FIXME: commented out because otherwise ColumnOperations stop working
          # def #{interfacep}(*args)
          #   flash :warning => "API point '#{interfacep}' is not implemented for widget '#{short_widget_class_name}'"
          #   {:flash => @flash}
          # end
          END
        end
      end

      def interface_points
        read_inheritable_attribute(:interface_points)
      end
      
      # returns an instance of a widget defined in the config
      def instance_by_config(config)
        widget_class = "Netzke::#{config[:widget_class_name]}".constantize
        widget_class.new(config)
      end
      
      def persistent_config_manager_class
        Netzke::Base.config[:persistent_config_manager].constantize
      rescue NameError
        nil
      end

      def layout_manager_class
        Netzke::Base.config[:layout_manager].constantize
      rescue NameError
        nil
      end
      
      private
      def set_default_config(default_config)
        @@config ||= {}
        @@config[self.name] ||= default_config
        @@config[self.name]
      end
      
    end
    extend ClassMethods
    
    attr_accessor :config, :server_confg, :parent, :logger, :id_name, :permissions
    attr_reader :pref

    def initialize(config = {}, parent = nil)
      @config  = initial_config.recursive_merge(config)
      @parent  = parent
      @id_name = parent.nil? ? config[:name].to_s : "#{parent.id_name}__#{config[:name]}"
      
      @flash = []
      
      @config[:ext_config] ||= {} # configuration used to instantiate JS class

      process_permissions_config
    end

    # Rails' logger
    def logger
      Rails.logger
    end
    
    # Store some setting in the database as if it was a hash, e.g.:
    #     persistent_config["window.size"] = 100
    #     persistent_config["window.size"] => 100
    # This method is current_user-aware
    def persistent_config
      config_klass = self.class.persistent_config_manager_class
      config_klass && config_klass.widget_name = id_name # pass to the config class our unique name
      config_klass || {} # if we don't have the presistent config manager, all the calls to it will always return nil, and the "="-operation will be ignored
    end
    
    def initial_config
      {}
    end

    # 'Netzke::Grid' => 'Grid'
    def short_widget_class_name
      self.class.short_widget_class_name
    end
    
    interface :get_widget # every widget gets this

    ## Dependencies
    def dependencies
      @dependencies ||= begin
        non_late_aggregatees_widget_classes = non_late_aggregatees.values.map{|v| v[:widget_class_name]}
        (initial_dependencies + non_late_aggregatees_widget_classes << self.class.short_widget_class_name).uniq
      end
    end
    
    # override this method if you need some extra dependencies, which are not the aggregatees
    def initial_dependencies
      []
    end
    
    ### Aggregation
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
    
    # The difference between aggregatees and late aggregatees is the following: the former gets instantiated together with its aggregator and is normally *instantly* visible as a part of it (for example, the widget in the initially expanded panel in an Accordion). A late aggregatee doesn't get instantiated along with its aggregator. Until it gets requested from the server, it doesn't take any part in its aggregator's life. An example of late aggregatee could be a widget that is loaded dynamically into a previously collapsed panel of an Accordion, or a preferences window (late aggregatee) for a widget (aggregator) that only gets shown when user wants to edit widget's preferences.
    def initial_late_aggregatees
      {}
    end
    
    def add_late_aggregatee(aggr)
      aggregatees.merge!(aggr.merge(:late_aggregation => true))
    end

    # recursively instantiates an aggregatee based on its "path": e.g. if we have an aggregatee :aggr1 which in its turn has an aggregatee :aggr10, the path to the latter would be "aggr1__aggr10"
    def aggregatee_instance(name)
      aggregator = self
      name.to_s.split('__').each do |aggr|
        aggr = aggr.to_sym
        # TODO: should we put all the classes under Netzke::-scope?
        # widget_class = full_widget_class_name(aggregator.aggregatees[aggr][:widget_class_name]).constantize
        widget_class = "Netzke::#{aggregator.aggregatees[aggr][:widget_class_name]}".constantize
        aggregator = widget_class.new(aggregator.aggregatees[aggr].merge(:name => aggr), aggregator)
      end
      aggregator
    end
    
    def full_widget_class_name(short_name)
      "Netzke::#{short_name}"
    end

    def flash(flash_hash)
      level = flash_hash.keys.first
      raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
      @flash << {:level => level, :msg => flash_hash[level]}
    end

    def widget_action(action_name)
      "#{@id_name}__#{action_name}"
    end

    # permissions
    def available_permissions
      []
    end

    def process_permissions_config
      if !available_permissions.empty?
        # First, process permissions from the config
        @permissions = available_permissions.inject({}){|h,p| h.merge(p.to_sym => true)} # by default anything is allowed

        config[:prohibit] = available_permissions if config[:prohibit] == :all # short-cut for all permissions
        config[:prohibit] = [config[:prohibit]] if config[:prohibit].is_a?(Symbol) # so that config[:prohibit] => :write works
        config[:prohibit] && config[:prohibit].each{|p| @permissions.merge!(p.to_sym => false)} # prohibit

        config[:allow] = [config[:allow]] if config[:allow].is_a?(Symbol) # so that config[:allow] => :write works
        config[:allow] && config[:allow].each{|p| @permissions.merge!(p.to_sym => true)} # allow
        
        # ... and then merge it with NetzkePreferences
        available_permissions.each do |p|
          persistent_permisson = persistent_config["permissions.#{p}"]
          @permissions[p.to_sym] = persistent_permisson unless persistent_permisson.nil?
        end
      end
    end

    ## method dispatcher - sends method to the proper aggregatee
    def method_missing(method_name, params = {})
      widget, *action = method_name.to_s.split('__')
      widget = widget.to_sym
      action = !action.empty? && action.join("__").to_sym
      
      if action && aggregatees[widget]
        # only actions starting with "interface_" are accessible
        interface_action = action.to_s.index('__') ? action : "interface_#{action}"
        aggregatee_instance(widget).send(interface_action, params)
      else
        super
      end
    end

    #### Interface
    def get_widget(params = {})
      # if browser does not have our component class cached (and all dependencies), send it to him
      components_cache = (JSON.parse(params[:components_cache]) if params[:components_cache]) || []
      
      {:config => js_config, :class_definition => js_missing_code(components_cache)}
    end
   
  end
end