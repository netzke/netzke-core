require 'netzke/base_extras/js_builder'
require 'netzke/base_extras/api'

module Netzke
  
  # Base class for every Netzke widget
  #
  # To instantiate a widget in the controller do
  #
  #   netzke :widgetname, configuration_hash
  # 
  # Configuration hash may contain the following config options common for every widget:
  # 
  # * <tt>:widget_class_name</tt> - name of the widget class in the scope of the Netzke module, e.g. "FormPanel"
  # * <tt>:ext_config</tt> - a config hash that is used to create a javascript instance of the widget. With the other words, every configuration that comes here will be available inside the javascript instance of the widget. For example:
  #
  #     netzke :books, :widget_class_name => "GridPanel", :ext_config => {:icon_cls => 'icon-grid', :title => "Books"}
  # 
  
  class Base
    
    # api
    def load_aggregatee(params)
      widget = aggregatee_instance(params[:id])
      {:this => [{:eval_js => widget.js_missing_code, :eval_css => css_missing_code}, {:render_widget_in_container => {:container => "#{self.id_name}_#{params[:id]}", :config => widget.js_config}}]}
    end



    # Class-level Netzke::Base configuration. The defaults also get specified here.
    def self.config
      set_default_config({
        # which javascripts and stylesheets must get included at the initial load (see netzke-core.rb)
        :javascripts               => [],
        :stylesheets               => [],
        :persistent_config_manager => "NetzkePreference",
        :ext_location              => defined?(RAILS_ROOT) && "#{RAILS_ROOT}/public/extjs"
      })
    end

    include Netzke::BaseExtras::JsBuilder
    
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

      def session=(s)
        @@session = s
      end

      # called by controller at the moment of successfull login
      def login
        session[:_netzke_next_request_is_first_after_login] = true
      end
      
      # called by controller at the moment of logout
      def logout
        session[:_netzke_next_request_is_first_after_logout] = true
      end

      #
      # Use this class method to declare connection points between client side of a widget and its server side. A method in a widget class with the same name will be (magically) called by the client side of the widget. See Grid widget for an example
      #
      def api(*api_points)
        apip = read_inheritable_attribute(:api_points) || []
        api_points.each{|p| apip << p}
        write_inheritable_attribute(:api_points, apip)

        # It may be needed later for security
        api_points.each do |apip|
          module_eval <<-END, __FILE__, __LINE__
          def api_#{apip}(*args)
            #{apip}(*args).to_nifty_json
          end
          # FIXME: commented out because otherwise ColumnOperations stop working
          # def #{apip}(*args)
          #   flash :warning => "API point '#{apip}' is not implemented for widget '#{short_widget_class_name}'"
          #   {:flash => @flash}
          # end
          END
        end
      end

      def api_points
        read_inheritable_attribute(:api_points)
      end
      
      # returns an instance of a widget defined in the config
      def instance_by_config(config)
        widget_class = "Netzke::#{config[:widget_class_name]}".constantize
        widget_class.new(config)
      end
      
      # persistent_config and layout manager classes
      def persistent_config_manager_class
        Netzke::Base.config[:persistent_config_manager].try(:constantize)
      rescue NameError
        nil
      end

      # Return persistent config class
      def persistent_config
        # if the class is not present, fake it (it will not store anything, and always return nil)
        if persistent_config_manager_class.nil?
          fake_config = {}
          class << fake_config
            def for_widget(*params, &block)
              yield({})
            end
            def widget_name=(*params)
            end
          end
          fake_config
        else
          persistent_config_manager_class
        end
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

    api :load_aggregatee # every widget has this api

    def initialize(config = {}, parent = nil)
      @session = Netzke::Base.session

      # Uncomment for application-wide weak/strong default config for widgets
      # @config  = (session[:weak_default_config] || {}).
      #   recursive_merge(initial_config).
      #   recursive_merge(config).
      #   recursive_merge(session[:strong_default_config] || {})

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

    # configuration of all children will get recursive_merge'd with strong_children_config
    def strong_children_config= (c)
      @strong_children_config = c
    end
    
    def strong_children_config
      @strong_children_config ||= {}
    end
    
    # configuration of all children will get reverse_recursive_merge'd with weak_children_config
    def weak_children_config= (c)
      @weak_children_config = c
    end
    
    def weak_children_config
      @weak_children_config ||= {}
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
      if config[:persistent_config]
        config_class = self.class.persistent_config
        config_class.widget_name = id_name # pass to the config class our unique name
        config_class
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
    
    # api :get_widget # every widget gets this

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
    def aggregatee_instance(name, strong_config = {})
      aggregator = self
      name.to_s.split('__').each do |aggr|
        aggr = aggr.to_sym
        short_class_name = aggregator.aggregatees[aggr][:widget_class_name]
        raise ArgumentError, "No widget_class_name specified for aggregatee #{aggr} of #{aggregator.config[:name]}" if short_class_name.nil?
        widget_class = "Netzke::#{short_class_name}".constantize

        conf = weak_children_config.
          recursive_merge(aggregator.aggregatees[aggr]).
          recursive_merge(strong_children_config).
          recursive_merge(strong_config). # we may want to reconfigure the aggregatee at the moment of instantiation
          merge(:name => aggr)

        aggregator = widget_class.new(conf, aggregator) # params: config, parent
        aggregator.weak_children_config = weak_children_config
        aggregator.strong_children_config = strong_children_config
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
    def persistent_config_manager_class
      self.class.persistent_config_manager_class
    end

    # this should go into base_extras/api.rb
    def load_aggregatee(params)
      widget = aggregatee_instance(params[:id])
      {:this => [{:eval_js => widget.js_missing_code, :eval_css => css_missing_code}, {:render_widget_in_container => {:container => params[:container], :config => widget.js_config}}]}
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
    
  end
end