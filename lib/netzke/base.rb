require 'active_support/core_ext'
require 'netzke/core/ruby_ext'
require 'netzke/core/dsl_support'
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
require 'netzke/core/html' if Module.const_defined?(:Haml)

module Netzke
  # The base class for every Netzke component. Its main responsibilities include:
  # * JavaScript class generation and inheritance (using Ext JS class system) which reflects the Ruby class inheritance (see {Netzke::Core::Javascript})
  # * Nesting and dynamic loading of child components (see {Netzke::Core::Composition})
  # * Ruby-side action declaration (see {Netzke::Actions})
  # * I18n
  # * Client-server communication (see {Netzke::Core::Services})
  # * Session-based persistence (see {Netzke::Core::State})
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
    include Core::DslSupport
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
    include Core::Html if const_defined? :Haml

    # TODO: get rid of it
    class_attribute :default_instance_config
    self.default_instance_config = {}

    # set during initializations
    mattr_accessor :session
    mattr_accessor :controller
    mattr_accessor :logger

    # Parent component
    attr_reader :parent

    # Name that the parent can reference us by
    attr_reader :name

    # Global id in the component tree, following the double-underscore notation, e.g. +books__config_panel__form+
    attr_reader :js_id

    # JS id in the context of the parent
    attr_reader :item_id

    # Component's path in the component tree
    attr_reader :path

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
      @passed_config = conf

      # parent component
      @parent = parent

      # name fo the component used in the +component+ DSL block, and is a part of component's +@path+
      @name = conf[:name] || self.class.name.underscore

      # path down the composition hierarchy (composed of names)
      @path = parent.nil? ? @name : "#{parent.path}__#{@name}"

      # JS id in the scope of the parent component. Auto-generated when using multiple instance loading.
      # Full JS id will be built using these along the +@path+
      @item_id = conf[:item_id] || @name

      # JS full ID. Similar to +path+, but composed of item_id's. Differs from @path when multiple instances are being loaded.
      @js_id = parent.nil? ? @item_id : [parent.js_id, @item_id].join("__")

      # TODO: get rid of this in 0.9
      @flash = []

      # Make +client_config+ accessible in +configure+ before calling +super+
      config.client_config = conf.delete(:client_config) || {}

      # Build complete component configuration
      configure(config)
    end

    def i18n_id
      self.class.i18n_id
    end

  private

    # TODO: get rid of this in 0.9
    def flash(flash_hash)
      level = flash_hash.keys.first
      raise "Unknown message level for flash" unless %(notice warning error).include?(level.to_s)
      @flash << {:level => level, :msg => flash_hash[level]}
    end

  end
end
