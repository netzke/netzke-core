require 'active_support/core_ext'
require 'netzke/core/ruby_ext'
require 'netzke/core/javascript'
require 'netzke/core/stylesheets'
require 'netzke/core/services'
require 'netzke/core/composition'
require 'netzke/core/plugins'
require 'netzke/core/configuration'
require 'netzke/core/state'
require 'netzke/core/embedding'
require 'netzke/core/actions'
require 'netzke/core/session'

module Netzke
  # The base class for every Netzke component. Its main responsibilities include:
  # * JavaScript class generation and inheritance (using Ext JS class system) which reflects the Ruby class inheritance (see {Netzke::Core::Javascript})
  # * Nesting and dynamic loading of child components (see {Netzke::Core::Composition})
  # * Ruby-side action declaration (see {Netzke::Actions})
  # * I18n
  # * Client-server communication (see {Netzke::Core::Services})
  # * Session-based persistence (see {Netzke::Core::State})
  #
  # == Class-level configuration
  #
  # Netzke::Base provides the following class-level configuration options:
  # * default_instance_config - a hash that will be used as default configuration for ALL of this component's instances.
  #
  # == Referring to JavaScript configuration methods from Ruby
  #
  # Netzke allows use Ruby symbols for referring to pre-defined pieces of configuration. Let's say for example, that a toolbar needs to nest a control more complex than a button (say, a date field), and a component should still make it possible to make it's presence and position in the toolbar configurable. We can implement it like this:
  #
  #     action :do_something
  #
  #     def configure(c)
  #       super
  #       c.tbar = [:do_something, :date_selector]
  #     end
  #
  # While :do_something here is referring to a usual Netzke action, :date_selector is not declared in actions. If our JavaScript mixin file contains a method called `dateSelectorConfig`, it will be executed at the moment of configuring `tbar` at client side, and it's result, a config object, will substitute `date_selector`:
  #
  #     {
  #       dateSelectorConfig: function(config){
  #         return {
  #           xtype: 'datefield'
  #         }
  #       }
  #     }
  #
  # This doesn't necessarily have to be used in toolbars, but also in other places in config (i.e. layouts).
  class Base
    include Core::Session
    include Core::State
    include Core::Configuration
    include Core::Javascript
    include Core::Services
    include Core::Composition
    include Core::Plugins
    include Core::Stylesheets
    include Core::Embedding
    include Core::Actions

    class_attribute :default_instance_config
    self.default_instance_config = {}

    # set during initializations
    mattr_accessor :session
    mattr_accessor :controller
    mattr_accessor :logger

    # Parent component
    attr_reader :parent

    # Name that the parent can reference us by. The last part of +js_id+
    attr_reader :name

    # Global id in the components tree, following the double-underscore notation, e.g. +books__config_panel__form+
    attr_reader :js_id

    class << self
      # Instance of component by config
      def instance_by_config(config)
        klass = config[:klass] || config[:class_name].constantize
        klass.new(config)
      end

      # The ID used to locate this component's block in locale files
      def i18n_id
        name.split("::").map{|c| c.underscore}.join(".")
      end

      # Do class-level config of a component, e.g.:
      #
      #   Netzke::Basepack::GridPanel.setup do |c|
      #     c.rows_reordering_available = false
      #   end
      def self.setup
        yield self
      end

      # Ancestor classes in the Netzke class hierarchy up to (and excluding) +Netzke::Base+, including self; in comparison to Ruby's own Class.ancestors, the order is reversed.
      def netzke_ancestors
        if self == Netzke::Base
          []
        else
          superclass.netzke_ancestors + [self]
        end
      end
    end

    # Instantiates a component instance. A parent can optionally be provided.
    def initialize(conf = {}, parent = nil)
      @passed_config = conf # configuration passed at the moment of instantiation
      @passed_config.deep_freeze
      @parent        = parent
      @name          = conf[:name] || self.class.name.underscore
      @js_id         = parent.nil? ? @name : "#{parent.js_id}__#{@name}"
      @flash         = []

      # Build complete component configuration
      configure(config)
    end

    def i18n_id
      self.class.i18n_id
    end

  private

    # TODO: needs rework
    # TODO: rename to smth more appropriate
    def flash(flash_hash) #:nodoc:
      level = flash_hash.keys.first
      raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
      @flash << {:level => level, :msg => flash_hash[level]}
    end

  end
end
