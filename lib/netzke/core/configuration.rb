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
      # passed config
      c.merge!(@passed_config)
    end

    # Complete server class configuration. Can be accessed from within endpoint, component, and action blocks, as well as any other instance method, for example:
    #
    #   action :do_something do |c|
    #     c.title = "Do it for #{config.title}"
    #   end
    def config
      @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
