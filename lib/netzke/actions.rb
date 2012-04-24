module Netzke
  # Netzke components allow specifying Ext actions (see http://dev.sencha.com/deploy/dev/docs/?class=Ext.Action)
  #
  # == Defining actions in a component
  # The 2 ways to define an action are:
  # * as a hash, e.g:
  #
  #     action :bug_server, :text => "Call server", :icon => :phone
  #
  # (if the same action was defined in the super class, the superclass's definition get merged with the current definition)
  #
  # * as a block, in case you need access to the component's instance, e.g.:
  #     action :bug_server do
  #       {:text => config[:text], :disabled => true}
  #     end
  #
  # Both of the ways result in a definition of an instance method named {action_name}_action. So, overriding an action in the child class is done be redefining the method, e.g.:
  #
  #     def bug_server_action
  #       # super will have the superclass's action definition
  #     end
  #
  # == I18n of actions
  # The text and tooltip for an action will be automatically picked up from a locale file when possible.
  # E.g., an action named "some_action" and defined in the component +MyComponents::CoolComponent+, will look for its text in:
  #
  #     I18n.t('my_components.cool_component.actions.some_action')
  #
  # and for its tooltip in:
  #
  #     I18n.t('my_components.cool_component.actions.some_action_tooltip')
  module Actions
    extend ActiveSupport::Concern

    ACTION_METHOD_NAME = "%s_action"

    included do
      alias_method_chain :js_config, :actions

      # Returns registered actions
      class_attribute :registered_actions
      self.registered_actions = []
    end

    module ClassMethods
      def action(name, &block)
        register_action(name)

        method_name = ACTION_METHOD_NAME % name
        if block_given?
          define_method(method_name, &block)
        else
          define_method(method_name) do |action_config|
            action_config
          end
        end
      end

      # Register an action
      def register_action(name)
        self.registered_actions |= [name]
      end
    end

    # All actions for this instance
    def actions
      @actions ||= self.class.registered_actions.inject({}) do |res, name|
        action_config = Netzke::ActionConfig.new(name, self)
        send(ACTION_METHOD_NAME % name, action_config)
        res.merge(name.to_sym => action_config)
      end
    end

    def js_config_with_actions #:nodoc
      actions.empty? ? js_config_without_actions : js_config_without_actions.merge(:actions => actions)
    end

  protected

    def uri_to_icon(icon)
      Netzke::Core.uri_to_icon(icon)
    end
  end
end
