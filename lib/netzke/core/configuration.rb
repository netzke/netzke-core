module Netzke::Core
  # Components can implement class-level config options by using `class_attribute`, e.g.:
  #
  #   class MyComponent < Netzke::Base
  #     class_attribute :title
  #     self.title = "Title for all descendants of MyComponent"
  #
  #     js_configure do |c|
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
      def setup
        yield self
      end

      # An array of server class config options that should not be passed to the client class. Can be overridden.
      def server_side_config_options
        [:eager_loading, :klass]
      end
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

    # Complete configuration for server class instance. Can be accessed from within endpoint, component, and action blocks, as well as any other instance method, for example:
    #
    #   action :do_something do |c|
    #     c.title = "Do it for #{config.title}"
    #   end
    def config
      @config ||= ActiveSupport::OrderedOptions.new
    end

  protected

    # Override to validate configuration and raise eventual exceptions
    # E.g.:
    #
    #     def validate_config(c)
    #       raise ArgumentError, "Grid requires a model" if c.model.nil?
    #     end
    def validate_config(c)
    end

    # During the normalization of config object, +extend_item+ is being called with each item found (recursively) in there.
    # For example, symbols representing nested child components get replaced with a proper config hash, same goes for actions (see +Composition+ and +Actions+ respectively).
    # Override to do any additional checks/enhancements. See, for example, +Netzke::Basepack::WrapLazyLoaded+ or +Netzke::Basepack::Fields+.
    # @return [Object|nil] normalized item or nil. If nil is returned, this item will be excluded from the config.
    def extend_item(item)
      item.is_a?(Hash) && item[:excluded] ? nil : item
    end

    # Used for detecting actions and components referred by symbols. For example, say, action +do_something+ is declared. Then:
    #
    #     item #=> :do_something
    #     item = detect_and_normalize :action, item
    #     item #=> {netzke_action: :do_something, text: 'Do it'} # uses action declaration
    def detect_and_normalize(thing, item)
      if item.is_a?(Symbol) && thing_config = send(thing.to_s.pluralize)[item]
        item = {:"netzke_#{thing}" => item, excluded: thing_config[:excluded]}
      elsif item.is_a?(Hash)
        # replace `action` key with `netzke_action`, which will be looked for at the JS side
        item[:"netzke_#{thing}"] = item.delete(thing) if item[thing]
      end
      item
    end

    # We'll build a couple of useful instance variables here:
    #
    # +components_in_config+ - an array of components (by name) referred in items
    # +normalized_config+ - a config that has all the config extensions applied
    def normalize_config
      @components_in_config = []
      c = config.dup
      config.each_pair do |k, v|
        c.delete(k) if self.class.server_side_config_options.include?(k.to_sym)
        if v.is_a?(Array)
          c[k] = v.netzke_deep_map{|el| extend_item(el)}
        end
      end
      @normalized_config = c
    end

    # @return [Hash] config with all placeholders (like child components referred by symbols) expanded
    def normalized_config
      # make sure we call normalize_config first
      @normalized_config || (normalize_config || true) && @normalized_config
    end
  end
end
