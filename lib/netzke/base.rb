require 'netzke/base_js'

module Netzke
  # = Base
  # Base class for every Netzke widget
  #
  # To instantiate a widget in the controller:
  #
  #     netzke :widget_name, configuration_hash
  # 
  # == Configuration
  # * <tt>:widget_class_name</tt> - name of the widget class in the scope of the Netzke module, e.g. "FormPanel".
  # When a widget is defined in the controller and this option is omitted, widget class is deferred from the widget's
  # name. E.g.:
  # 
  #   netzke :grid_panel, :data_class_name => "User"
  # 
  # In this case <tt>:widget_class_name</tt> is assumed to be "GridPanel"
  # 
  # * <tt>:ext_config</tt> - a config hash that is used to create a javascript instance of the widget. Every
  # configuration that comes here will be available inside the javascript instance of the widget.
  # * <tt>:persistent_config</tt> - if set to <tt>true</tt>, the widget will use persistent storage to store its state;
  # for instance, Netzke::GridPanel stores there its columns state (width, visibility, order, headers, etc).
  # A widget may or may not provide interface to its persistent settings. GridPanel and FormPanel from netzke-basepack
  # are examples of widgets that by default do.
  # 
  # Examples of configuration:
  #
  #     netzke :books, 
  #       :widget_class_name => "GridPanel", 
  #       :data_class_name => "Book", # GridPanel specific option
  #       :persistent_config => false, # don't use persistent config for this instance
  #       :ext_config => {
  #         :icon_cls => 'icon-grid', 
  #         :title => "My books"
  #       }
  # 
  #     netzke :form_panel, 
  #       :data_class_name => "User" # FormPanel specific option
  class Base
    include Netzke::BaseJs # javascript (client-side)

    module ClassMethods
      # Class-level Netzke::Base configuration. The defaults also get specified here.
      def config
        set_default_config({
          # which javascripts and stylesheets must get included at the initial load (see netzke-core.rb)
          :javascripts               => [],
          :stylesheets               => [],
          
          :persistent_config_manager => "NetzkePreference",
          :ext_location              => defined?(RAILS_ROOT) && "#{RAILS_ROOT}/public/extjs",
          :default_config => {
            :persistent_config => true
          }
        })
      end

      def configure(*args)
        if args.first.is_a?(Symbol)
          # first arg is a Symbol
          config[args.first] = args.last
        else
          config.deep_merge!(args.first)
        end

        enforce_config_consistency
      end
      
      def enforce_config_consistency; end

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

      # Use this class method to declare connection points between client side of a widget and its server side. 
      # A method in a widget class with the same name will be (magically) called by the client side of the widget. 
      # See netzke-basepack's GridPanel for an example.
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
          {}
        else
          persistent_config_manager_class
        end
      end
      
      private
      def set_default_config(c)
        @@config ||= {}
        @@config[self.name] ||= c
      end
      
    end
    extend ClassMethods
    
    # If the widget has persistent config in its disposal
    def persistent_config_enabled?
      !persistent_config_manager_class.nil? && config[:persistent_config]
    end
    
    attr_accessor :parent, :name, :global_id, :permissions, :session

    api :load_aggregatee_with_cache # every widget gets this api

    # Widget initialization process
    # * the config hash is available to the widget after the "super" call in the initializer
    # * override/add new default configuration options into the "default_config" method 
    # (the config hash is not yet available)
    def initialize(config = {}, parent = nil)
      @session       = Netzke::Base.session
      @passed_config = config # configuration passed at the moment of instantiation
      @parent        = parent
      @name          = config[:name].nil? ? short_widget_class_name.underscore : config[:name].to_s
      @global_id     = parent.nil? ? @name : "#{parent.global_id}__#{@name}"
      @flash         = []
    end

    def default_config
      self.class.config[:default_config].nil? ? {} : {}.merge!(self.class.config[:default_config])
    end

    # Access to the config that takes into account all possible ways to configure a widget. *Read only*.
    def config
      # Translates into something like this:
      #     @config ||= default_config.
      #                 deep_merge(@passed_config).
      #                 deep_merge(persistent_config_hash).
      #                 deep_merge(strong_parent_config).
      #                 deep_merge(strong_session_config)
      @config ||= independent_config.
                    deep_merge(strong_parent_config).
                    deep_merge(strong_session_config)
                    
    end
    
    def flat_config(key = nil)
      fc = config.flatten_with_type
      key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
    end

    def strong_parent_config
      @strong_parent_config ||= parent.nil? ? {} : parent.strong_children_config
    end

    # Config that is not overwritten by parents and sessions
    def independent_config
      @independent_config ||= initial_config.deep_merge(persistent_config_hash)
    end

    def flat_independent_config(key = nil)
      fc = independent_config.flatten_with_type
      key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
    end
    
    def flat_default_config(key = nil)
      fc = default_config.flatten_with_type
      key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
    end

    # Static, hardcoded config. Consists of default values merged with config that was passed during instantiation
    def initial_config
      @initial_config ||= default_config.deep_merge(@passed_config)
    end
    
    def flat_initial_config(key = nil)
      fc = initial_config.flatten_with_type
      key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
    end

    def build_persistent_config_hash
      return {} if !initial_config[:persistent_config]
      
      prefs = NetzkePreference.find_all_for_widget(global_id)
      res = {}
      prefs.each do |p|
        hsh_levels = p.name.split("__").map(&:to_sym)
        tmp_res = {} # it decends into itself, building itself
        anchor = {} # it will keep the tail of tmp_res
        hsh_levels.each do |level_prefix|
          tmp_res[level_prefix] ||= level_prefix == hsh_levels.last ? p.normalized_value : {}
          anchor = tmp_res[level_prefix] if level_prefix == hsh_levels.first
          tmp_res = tmp_res[level_prefix]
        end
        # Now 'anchor' is a hash that represents the path to the single value, 
        # for example: {:ext_config => {:title => 100}} (which corresponds to ext_config__title)
        # So we need to recursively merge it into the final result
        res.deep_merge!(hsh_levels.first => anchor)
      end
      res
    end

    def persistent_config_hash
      @persistent_config_hash ||= build_persistent_config_hash
    end

    def ext_config
      config[:ext_config] || {}
    end
    
    # Like normal config, but stored in session
    def weak_session_config
      widget_session[:weak_session_config] ||= {}
    end

    def strong_session_config
      widget_session[:strong_session_config] ||= {}
    end

    # configuration of all children will get deep_merge'd with strong_children_config
    # def strong_children_config= (c)
    #   @strong_children_config = c
    # end

    # This config will be picked up by all the descendants
    def strong_children_config
      @strong_children_config ||= parent.nil? ? {} : parent.strong_children_config
    end
    
    # configuration of all children will get reverse_deep_merge'd with weak_children_config
    # def weak_children_config= (c)
    #   @weak_children_config = c
    # end
    
    def weak_children_config
      @weak_children_config ||= {}
    end
    
    def widget_session
      session[global_id] ||= {}
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
    def persistent_config(global = false)
      if config[:persistent_config]
        config_class = self.class.persistent_config
        config_class.widget_name = global ? nil : config[:persistent_config_id] || global_id # pass to the config class our unique name
        config_class
      else
        # if we can't use presistent config, all the calls to it will always return nil, and the "="-operation will be ignored
        logger.debug "==> NETZKE: no persistent config is set up for widget '#{global_id}'"
        {}
      end
    end
    
    # 'Netzke::Grid' => 'Grid'
    def short_widget_class_name
      self.class.short_widget_class_name
    end
    
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

    # recursively instantiates an aggregatee based on its "path": e.g. if we have an aggregatee :aggr1 which in its turn has an aggregatee :aggr10, the path to the latter would be "aggr1__aggr10"
    def aggregatee_instance(name, strong_config = {})
      aggregator = self
      name.to_s.split('__').each do |aggr|
        aggr = aggr.to_sym
        aggregatee_config = aggregator.aggregatees[aggr]
        raise ArgumentError, "No aggregatee '#{aggr}' defined for widget '#{aggregator.global_id}'" if aggregatee_config.nil?
        short_class_name = aggregatee_config[:widget_class_name]
        raise ArgumentError, "No widget_class_name specified for aggregatee #{aggr} of #{aggregator.global_id}" if short_class_name.nil?
        widget_class = "Netzke::#{short_class_name}".constantize

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
    
    def full_widget_class_name(short_name)
      "Netzke::#{short_name}"
    end

    def flash(flash_hash)
      level = flash_hash.keys.first
      raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
      @flash << {:level => level, :msg => flash_hash[level]}
    end

    def widget_action(action_name)
      "#{@global_id}__#{action_name}"
    end

    # called when the method_missing tries to processes a non-existing aggregatee
    def aggregatee_missing(aggr)
      flash :error => "Unknown aggregatee #{aggr} for widget #{name}"
      {:feedback => @flash}.to_nifty_json
    end

    def tools
      persistent_config[:tools] ||= config[:tools] || []
    end

    def menu
      persistent_config[:menu] ||= config[:menu] == false ? nil : config[:menu]
    end
    
    # some convenience for instances
    def persistent_config_manager_class
      self.class.persistent_config_manager_class
    end

    # override this method to do stuff at the moment of loading by some parent
    def before_load
      widget_session.clear
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

    # API: provides what is necessary for the browser to render a widget.
    # <tt>params</tt> should contain: 
    # * <tt>:cache</tt> - an array of widget classes cached at the browser
    # * <tt>:id</tt> - reference to the aggregatee
    # * <tt>:container</tt> - Ext id of the container where in which the aggregatee will be rendered
    def load_aggregatee_with_cache(params)
      cache = ActiveSupport::JSON.decode(params.delete(:cache))
      relative_widget_id = params.delete(:id).underscore.to_sym
      widget = aggregatees[relative_widget_id] && aggregatee_instance(relative_widget_id)
      
      if widget
        # inform the widget that it's being loaded
        widget.before_load
      
        [{
          :js => widget.js_missing_code(cache), 
          :css => widget.css_missing_code(cache)
        }, {
          :render_widget_in_container => {
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