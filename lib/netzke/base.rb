require 'active_support/core_ext'
require 'netzke/core_ext'
require 'netzke/javascript'
require 'netzke/stylesheets'
require 'netzke/services'
require 'netzke/composition'
require 'netzke/configuration'
require 'netzke/persistence'
require 'netzke/embedding'
require 'netzke/actions'
require 'netzke/session'

module Netzke
  # = Base
  # Base class for every Netzke component
  #
  # To instantiate a component in the controller:
  #
  #     netzke :component_name, configuration_hash
  # 
  # == Configuration
  # * <tt>:class_name</tt> - name of the component class in the scope of the Netzke module, e.g. "FormPanel".
  # When a component is defined in the controller and this option is omitted, component class is deferred from the component's
  # name. E.g.:
  # 
  #   netzke :grid_panel, :model => "User"
  # 
  # In this case <tt>:class_name</tt> is assumed to be "GridPanel"
  # 
  # * <tt>:persistent_config</tt> - if set to <tt>true</tt>, the component will use persistent storage to store its state;
  # for instance, Netzke::GridPanel stores there its columns state (width, visibility, order, headers, etc).
  # A component may or may not provide interface to its persistent settings. GridPanel and FormPanel from netzke-basepack
  # are examples of components that by default do.
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
    
    include Session
    include Persistence
    include Configuration
    include Javascript
    include Services
    include Composition
    include Stylesheets
    include Embedding
    include Actions

    attr_accessor :parent, :name, :global_id #, :permissions, :session

    # Component initialization process
    # * the config hash is available to the component after the "super" call in the initializer
    # * override/add new default configuration options into the "default_config" method 
    # (the config hash is not yet available)
    def initialize(conf = {}, parent = nil)
      @passed_config = conf # configuration passed at the moment of instantiation
      @passed_config.deep_freeze
      @parent        = parent
      @name          = conf[:name].nil? ? short_component_class_name.underscore : conf[:name].to_s
      @global_id     = parent.nil? ? @name : "#{parent.global_id}__#{@name}"
      @flash         = []
    end
  
    # Short component class name, e.g.: 
    #   Netzke::Module::SomeComponent => Module::SomeComponent
    def self.short_component_class_name
      self.name.sub(/^Netzke::/, "")
    end

    # Component class, given its name
    def self.constantize_class_name(class_name)
      "#{class_name}".constantize rescue "Netzke::#{class_name}".constantize
    end
    
    def constantize_class_name(class_name)
      self.class.constantize_class_name(class_name)
    end

    # Instance of component by config
    def self.instance_by_config(config)
      constantize_class_name(config[:class_name]).new(config)
    end
  
    def logger
      if defined?(Rails)
        Rails.logger
      else 
        require 'logger'
        Logger.new(STDOUT)
      end
    end
  
    # 'Netzke::Grid' => 'Grid'
    def short_component_class_name
      self.class.short_component_class_name
    end
  
    def flash(flash_hash)
      level = flash_hash.keys.first
      raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
      @flash << {:level => level, :msg => flash_hash[level]}
    end

    def self.read_clean_inheritable_hash(attr_name)
      res = read_inheritable_attribute(attr_name) || {}
      # We don't want here any values from the superclass (which is the consequence of using inheritable attributes).
      res == self.superclass.read_inheritable_attribute(attr_name) ? {} : res
    end
    
    # override this method to do stuff at the moment of loading by some parent
    def before_load
      # component_session.clear - we don't do it anymore
    end

  end
end