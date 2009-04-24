require 'netzke/base_extras/js_builder'
require 'netzke/base_extras/interface'

module Netzke
  class Base
    
    # Class-level Netzke::Base configuration. The defaults also get specified here.
    def self.config
      set_default_config({
        # which javascripts and stylesheets must get included at the initial load (see netzke-core.rb)
        :javascripts               => [],
        :stylesheets               => [],
        
        :layout_manager            => "NetzkeLayout",
        :persistent_config_manager => "NetzkePreference",
        
        :ext_location              => defined?(RAILS_ROOT) && "#{RAILS_ROOT}/public/extjs"
      })
    end

    include Netzke::BaseExtras::JsBuilder
    include Netzke::BaseExtras::Interface
    
    module ClassMethods

      # "Netzke::SomeWidget" => "SomeWidget"
      def short_widget_class_name
        self.name.split("::").last
      end

      # Multi-user support (deprecated in favor of controller sessions)
      def user
        @@user ||= nil
      end

      def user=(user)
        @@user = user
      end

      # Access to controller sessions
      def session
        @@session ||= {}
      end

      def session=(session)
        @@session = session
      end

      def update_session
        if session[:just_logged_in]
          session[:masq_user] = session[:masq_role] = nil
          session[:config_mode] = nil
          
          session[:just_logged_in] = nil
        end
        
        # backward compatibility deprecated
        Netzke::Base.user = session[:user]
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
      
      # persistent_config and layout manager classes
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
    
    attr_accessor :config, :server_confg, :parent, :logger, :id_name, :permissions, :session
    attr_reader :pref

    def initialize(config = {}, parent = nil)
      @config  = initial_config.recursive_merge(config)
      @parent  = parent
      @id_name = parent.nil? ? config[:name].to_s : "#{parent.id_name}__#{config[:name]}"
      
      @flash = []
      
      @config[:ext_config] ||= {} # configuration used to instantiate JS class
      
      @session = Netzke::Base.session

      process_permissions_config
    end

    # Rails' logger
    def logger
      Rails.logger
    end
    
    def dependency_classes
      res = []
      non_late_aggregatees.keys.each do |aggr|
        res += aggregatee_instance(aggr).dependency_classes
      end
      res << short_widget_class_name
      res.uniq
    end
    
    # Store some setting in the database as if it was a hash, e.g.:
    #     persistent_config["window.size"] = 100
    #     persistent_config["window.size"] => 100
    # This method is user-aware
    def persistent_config
      config_klass = config[:persistent_config] && self.class.persistent_config_manager_class
      if config_klass
        config_klass.widget_name = id_name # pass to the config class our unique name
        config_klass
      else
        # if we can't use presistent config, all the calls to it will always return nil, and the "="-operation will be ignored
        {}
      end
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
        short_class_name = aggregator.aggregatees[aggr][:widget_class_name]
        raise ArgumentError, "No widget_class_name specified for aggregatee #{aggr} of #{aggregator.config[:name]}" if short_class_name.nil?
        widget_class = "Netzke::#{short_class_name}".constantize
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
          # if nothing is stored in persistent_config, store the permission from the config; otherwise leave what's there
          persistent_config["permissions/#{p}"].nil? && persistent_config["permissions/#{p}"] = @permissions[p.to_sym]

          # what's stored in persistent_config has higher priority, so, if there's something there, use that
          persistent_permisson = persistent_config["permissions/#{p}"]
          @permissions[p.to_sym] = persistent_permisson unless persistent_permisson.nil?
        end
      end
    end

    # method dispatcher - sends method to the proper aggregatee
    def method_missing(method_name, params = {})
      widget, *action = method_name.to_s.split('__')
      widget = widget.to_sym
      action = !action.empty? && action.join("__").to_sym
      
      if action
        if aggregatees[widget]
          # only actions starting with "interface_" are accessible
          interface_action = action.to_s.index('__') ? action : "interface_#{action}"
          aggregatee_instance(widget).send(interface_action, params)
        else
          aggregatee_missing(widget)
        end
      else
        super
      end
    end

    # called when the method_missing tries to processes a non-existing aggregatee
    def aggregatee_missing(aggr)
      flash :error => "Unknown aggregatee #{aggr} for widget #{config[:name]}"
      {:success => false, :flash => @flash}.to_json
    end

    def tools
      persistent_config[:tools] ||= config[:tools] == false ? nil : config[:tools]
    end

    def bbar
      persistent_config[:bottom_bar] ||= config[:bbar] == false ? nil : config[:bbar]
    end

    def tbar
      persistent_config[:top_bar] ||= config[:tbar] == false ? nil : config[:tbar]
    end

    def menu
      persistent_config[:menu] ||= config[:menu] == false ? nil : config[:menu]
    end
    
    # some convenience for instances
    def layout_manager_class
      self.class.layout_manager_class
    end

    def persistent_config_manager_class
      self.class.persistent_config_manager_class
    end

  end
end