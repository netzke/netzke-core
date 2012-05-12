module Netzke
  # TODO: Document
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      def setup
        yield self
      end

      # Config options that should not go to the client side
      def server_side_config_options
        [:lazy_loading, :klass]
      end
    end

    def configure
      # default config
      config.merge!(self.class.default_instance_config)

      # passed config
      config.merge!(@passed_config)

      # persistent config
      config.merge!(persistent_options) if config[:persistence]

      # session options
      config.merge!(session_options) # if @config[:session_persistence]

      # parent config
      # config.merge!(parent.strong_children_config) unless parent.nil?
    end

    # Component's config
    def config
      @config ||= ActiveSupport::OrderedOptions.new
    end
  end
end
