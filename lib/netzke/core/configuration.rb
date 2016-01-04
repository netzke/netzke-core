module Netzke::Core
  # Components can implement class-level config options by using `class_attribute`, e.g.:
  #
  #   class MyComponent < Netzke::Base
  #     class_attribute :title
  #     self.title = "Title for all descendants of MyComponent"
  #
  #     client_class do |c|
  #       c.title = title
  #     end
  #   end
  #
  # Then before using MyComponent (e.g. in Rails' initializers), you can configure it like this:
  #
  #   MyComponent.title = "Better title"
  #
  # Alternatively, you can use the `Base.setup` method:
  #
  #   MyComponent.setup do |config|
  #     config.title = "Better title"
  #   end
  module Configuration
    extend ActiveSupport::Concern

    # Use to configure a component on the class level, for example:
    #
    #   MyComponent.setup do |config|
    #     config.enable_awesome_feature = true
    #   end
    module ClassMethods
      # Do class-level config of a component, e.g.:
      #
      #   Netzke::Basepack::GridPanel.setup do |c|
      #     c.rows_reordering_available = false
      #   end
      def setup
        yield self
      end

      # An array of server class config options that should not be passed to the client class. Can be overridden.
      def server_side_config_options
        [:klass, :client_config]
      end

      # Instance of component by config
      def instance_by_config(config)
        klass = config[:klass] || config[:class_name].constantize
        klass.new(config)
      end
    end

    included do
      # Config that has all the config extensions applied (via `extend_item`)
      attr_accessor :normalized_config
    end

    # Override to auto-configure components. Example:
    #
    #   class BookGrid < Netzke::Basepack::Grid
    #     def configure(c)
    #       super
    #       c.model = "Book"
    #     end
    #   end
    def configure(c)
      c.merge!(@passed_config)
    end

    # Complete configuration for server class instance. Can be accessed from within endpoint, component, and action
    # blocks, as well as any other instance method, for example:
    #
    #   action :do_something do |c|
    #     c.title = "Do it for #{config.title}"
    #   end
    def config
      @config ||= ActiveSupport::OrderedOptions.new
    end

    # Config options that have been set on the fly on the client side of the component in the `serverConfig` object. Can be
    # used to dynamically change component configuration. Those changes won't affect the way component is rendered, of
    # course, but can be useful to reconfigure child components, e.g.:
    #
    #   // Client
    #   initConfig: function() {
    #     this.callParent();
    #
    #     this.netzkeGetComponent('authors').on('rowclick', function(grid, record) {
    #       this.serverConfig.author_id = record.getId();
    #       this.netzkeGetComponent('book_grid').getStore().load();
    #     }
    #   }
    #
    #   # Server
    #   component :book_grid do |c|
    #     c.scope = { author_id: client_config.author_id }
    #   end
    def client_config
      @client_config ||= HashWithIndifferentAccess.new(config.client_config)
    end

    protected

    # Override to validate or enforce certain configuration options
    # E.g.:
    #
    #     def validate_config(c)
    #       raise ArgumentError, "Grid requires a model" if c.model.nil?
    #       c.paging = true if c.edit_inline
    #     end
    def validate_config(c)
    end

    # During the normalization of config object, +extend_item+ is being called with each item found (recursively) in
    # there.  For example, symbols representing nested child components get replaced with a proper config hash, same
    # goes for actions (see +Composition+ and +Actions+ respectively).  Override to do any additional
    # checks/enhancements. See, for example, +Netzke::Basepack::WrapLazyLoaded+ or +Netzke::Basepack::Fields+.
    # @return [Object|nil] normalized item or nil. If nil is returned, this item will be excluded from the config.
    def extend_item(item)
      item.is_a?(Hash) && item[:excluded] ? nil : item
    end

    # We'll build a couple of useful instance variables here:
    #
    # +components_in_config+ - an array of components (by name) referred in `configure`
    # +inline_components+ - a hash with configs of components defined inline in `configure`
    # +normalized_config+ - a config that has all the config extensions applied
    def normalize_config
      @components_in_config = []
      @implicit_component_index = 0
      @inline_components = {}
      c = config.dup
      config.each_pair do |k, v|
        c.delete(k) if self.class.server_side_config_options.include?(k.to_sym)
        if v.is_a?(Array)
          c[k] = v.netzke_deep_replace{|el| extend_item(el)}
        end
      end
      @normalized_config = c
    end
  end
end
