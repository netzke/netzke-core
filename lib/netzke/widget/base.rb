require 'active_support'
require 'netzke/widget/javascript'
require 'netzke/widget/stylesheets'
require 'netzke/widget/api'
require 'netzke/widget/aggregation'
require 'netzke/widget/configuration'
require 'netzke/widget/persistence'
require 'netzke/widget/embedding'

module Netzke
  module Widget
    # = Base
    # Base class for every Netzke widget
    #
    # To instantiate a widget in the controller:
    #
    #     netzke :widget_name, configuration_hash
    # 
    # == Configuration
    # * <tt>:class_name</tt> - name of the widget class in the scope of the Netzke module, e.g. "FormPanel".
    # When a widget is defined in the controller and this option is omitted, widget class is deferred from the widget's
    # name. E.g.:
    # 
    #   netzke :grid_panel, :model => "User"
    # 
    # In this case <tt>:class_name</tt> is assumed to be "GridPanel"
    # 
    # * <tt>:persistent_config</tt> - if set to <tt>true</tt>, the widget will use persistent storage to store its state;
    # for instance, Netzke::GridPanel stores there its columns state (width, visibility, order, headers, etc).
    # A widget may or may not provide interface to its persistent settings. GridPanel and FormPanel from netzke-basepack
    # are examples of widgets that by default do.
    # 
    # Examples of configuration:
    #
    #     netzke :books, 
    #       :class_name => "GridPanel", 
    #       :model => "Book", # GridPanel specific option
    #       :persistent_config => false, # don't use persistent config for this instance
    #       :icon_cls => 'icon-grid', 
    #       :title => "My books"
    # 
    #     netzke :form_panel, 
    #       :model => "User" # FormPanel specific option
    class Base
      
      include Persistence
      include Configuration
      include Javascript
      include Api
      include Aggregation
      include Stylesheets
      include Embedding
      include Actions

      attr_accessor :parent, :name, :global_id #, :permissions, :session

      # Widget initialization process
      # * the config hash is available to the widget after the "super" call in the initializer
      # * override/add new default configuration options into the "default_config" method 
      # (the config hash is not yet available)
      def initialize(config = {}, parent = nil)
        # @session       = Netzke::Base.session
        @passed_config = config # configuration passed at the moment of instantiation
        @parent        = parent
        @name          = config[:name].nil? ? short_widget_class_name.underscore : config[:name].to_s
        @global_id     = parent.nil? ? @name : "#{parent.global_id}__#{@name}"
        @flash         = []
      end
    
      # Short widget class name, e.g.: 
      #   Netzke::Module::SomeWidget => Module::SomeWidget
      def self.short_widget_class_name
        self.name.sub(/^Netzke::/, "")
      end

      # Instance of widget by config
      def self.instance_by_config(config)
        widget_class = "Netzke::#{config[:class_name]}".constantize
        widget_class.new(config)
      end
    
      def session
        Netzke::Main.session
      end
    
      def widget_session
        session[global_id] ||= {}
      end

      # Rails' logger
      def logger
        Rails.logger
      end
    
      # 'Netzke::Grid' => 'Grid'
      def short_widget_class_name
        self.class.short_widget_class_name
      end
    
      def full_class_name(short_name)
        "Netzke::Widget::#{short_name}"
      end

      def flash(flash_hash)
        level = flash_hash.keys.first
        raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
        @flash << {:level => level, :msg => flash_hash[level]}
      end

      def widget_action(action_name)
        "#{@global_id}__#{action_name}"
      end

      # def tools
      #   persistent_config[:tools] ||= config[:tools] || []
      # end
      # 
      # def menu
      #   persistent_config[:menu] ||= config[:menu] == false ? nil : config[:menu]
      # end
    
      # override this method to do stuff at the moment of loading by some parent
      def before_load
        widget_session.clear
      end

    end
  end
end