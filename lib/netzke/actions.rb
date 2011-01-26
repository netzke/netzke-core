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
    end

    module ClassMethods
      def action(name, config = {}, &block)
        register_action(name)
        config[:name] = name.to_s
        method_name = ACTION_METHOD_NAME % name

        if block_given?
          define_method(method_name, &block)
        else
          if superclass.instance_methods.map(&:to_s).include?(method_name)
            define_method(method_name) do
              super().merge(config)
            end
          else
            define_method(method_name) do
              config
            end
          end
        end
      end

      # Register an action
      def register_action(name)
        current_actions = read_inheritable_attribute(:actions) || []
        current_actions << name
        write_inheritable_attribute(:actions, current_actions.uniq)
      end

      # Returns registered actions
      def registered_actions
        read_inheritable_attribute(:actions) || []
      end

    end

    # All actions for this instance
    def actions
      @actions ||= self.class.registered_actions.inject({}){ |res, name| res.merge(name.to_sym => normalize_action_config(send(ACTION_METHOD_NAME % name).merge(:name => name.to_s))) }
    end

    def js_config_with_actions #:nodoc
      actions.empty? ? js_config_without_actions : js_config_without_actions.merge(:actions => actions)
    end

    private

      def normalize_action_config(config)
        if config[:icon].is_a?(Symbol)
          config[:icon] = uri_to_icon(config[:icon])
        end

        # Default text and tooltip
        default_text = I18n.t(i18n_id + ".actions." + config[:name], :default => config[:name].humanize)
        config[:text] ||= default_text
        config[:tooltip] ||= I18n.t(i18n_id + ".actions." + config[:name] + "_tooltip", :default => default_text)

        config
      end

      def uri_to_icon(icon)
        Netzke::Core.with_icons ? Netzke::Core.icons_uri + "/" + icon.to_s + ".png" : nil
      end
  end
end
