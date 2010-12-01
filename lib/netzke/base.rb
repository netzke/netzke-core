require 'active_support/core_ext'
require 'netzke/core_ext'
require 'netzke/javascript'
require 'netzke/stylesheets'
require 'netzke/services'
require 'netzke/composition'
require 'netzke/configuration'
require 'netzke/state'
require 'netzke/embedding'
require 'netzke/actions'
require 'netzke/session'

module Netzke
  # The base for every Netzke component
  #
  # == Class-level configuration
  # You can configure any component's class as follows:
  #     # e.g. in the initializers/netzke.rb
  #     MyComponent.setup do |config|
  #       config.default_instance_config = { :some_option => true }
  #     end
  #
  # Netzke::Base provides the following class-level configuration options:
  # * default_instance_config - a hash that will be used as default configuration for this component's instances
  class Base

    class_attribute :default_instance_config
    self.default_instance_config = {}

    include Session
    include State
    include Configuration
    include Javascript
    include Services
    include Composition
    include Stylesheets
    include Embedding
    include Actions

    # Parent component
    attr_reader :parent

    # Name that the parent can reference us by. The last part of +global_id+
    attr_reader :name

    # Global id in the components tree, following the double-underscore notation, e.g. +books__config_panel__form+
    attr_reader :global_id


		
    class << self
      # Component's short class name, e.g.:
      # "Netzke::Module::SomeComponent" => "Module::SomeComponent"
      def short_component_class_name
        self.name.sub(/^Netzke::/, "")
      end


      # Component's class, given its name
      def constantize_class_name(class_name)
        "#{class_name}".constantize
      rescue NameError
        "Netzke::#{class_name}".constantize
      end

      # Component's class, given its name
      def constantize_class_name_or_nil(class_name)
        "#{class_name}".constantize
      rescue NameError
        nil
      end

      # Instance of component by config
      def instance_by_config(config)
        constantize_class_name(config[:class_name]).new(config)
      end

      # All ancestor classes in the Netzke class hierarchy (i.e. up to Netzke::Base)
      def class_ancestors
        if self == Netzke::Base
          []
        else
          superclass.class_ancestors + [self]
        end
      end

      # Same as +read_inheritable_attribute+ returning a hash, but returns empty hash when it's equal to superclass's
      def read_clean_inheritable_hash(attr_name)
        res = read_inheritable_attribute(attr_name) || {}
        # We don't want here any values from the superclass (which is the consequence of using inheritable attributes).
        res == self.superclass.read_inheritable_attribute(attr_name) ? {} : res
      end

      # Same as +read_inheritable_attribute+ returning a hash, but returns empty hash when it's equal to superclass's
      def read_clean_inheritable_array(attr_name)
        res = read_inheritable_attribute(attr_name) || []
        # We don't want here any values from the superclass (which is the consequence of using inheritable attributes).
        res == self.superclass.read_inheritable_attribute(attr_name) ? [] : res
      end
		
		extend ActiveSupport::Memoizable
		memoize :constantize_class_name
		memoize :constantize_class_name_or_nil

    end

    # Instantiates a component instance. A parent can optionally be provided.
    def initialize(conf = {}, parent = nil)
      @passed_config = conf # configuration passed at the moment of instantiation
      @passed_config.deep_freeze
      @parent        = parent
      @name          = conf[:name].nil? ? short_component_class_name.underscore : conf[:name].to_s
      @global_id     = parent.nil? ? @name : "#{parent.global_id}__#{@name}"
      @flash         = []

      # initialize @components and @items
      normalize_components_in_items
      # auto_collect_actions_from_config_and_js_properties
    end

    # Proxy to the equally named class method
    def constantize_class_name(class_name)
      self.class.constantize_class_name(class_name)
    end

    # Proxy to the equally named class method
    def short_component_class_name
      self.class.short_component_class_name
    end

    # Override this method to do stuff at the moment of first-time loading
    def before_load
    end

    private

      def logger #:nodoc:
        if defined?(::Rails)
          ::Rails.logger
        else
          require 'logger'
          Logger.new(STDOUT)
        end
      end

      def flash(flash_hash) #:nodoc:
        level = flash_hash.keys.first
        raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
        @flash << {:level => level, :msg => flash_hash[level]}
      end

  end
end
