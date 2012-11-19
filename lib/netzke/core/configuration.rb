module Netzke::Core
  # TODO: Document
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def setup
        yield self
      end

      # Config options that should not go to the client side
      def server_side_config_options
        [:eager_loading, :klass]
      end
    end

    def configure(c)
      # default config
      c.reverse_merge!(self.class.default_instance_config)

      # passed config
      c.merge!(@passed_config)
    end

    # Component's config
    def config
      @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
