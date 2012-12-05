module Netzke::Core
  # Netzke components allow specifying Ext actions (see http://docs.sencha.com/ext-js/4-1/#!/api/Ext.Action) in Ruby code.
  #
  # == Defining actions
  #
  # An action is defined with the +action+ class method that accepts a block:
  #
  #     action :destroy do |c|
  #       c.text = "Destroy!"
  #       c.tooltip = "Destroying it all"
  #       c.icon = :delete
  #       c.handler = :destroy_something # destroySomething will be called on JavaScript side
  #     end
  #
  # All config settings for an action are optional. When omitted, the locale files will be consulted first (see "I18n of actions"), falling back to the defaults.
  #
  # [+icon+]
  #   Can be set to either a String (which will be interpreted as a full URI to the icon file), or as a Symbol, which will be expanded to +Netzke::Core.icons_uri+ + "/(icon).png". Defaults to nil (no icon)
  # [+handler+]
  #   A symbol that represents the JavaScript public method (snake-case), which will be called in the scope of the component instance. Defaults to +on_(action_name)+, which on JavaScript side will result in a call to +on(CamelCaseActionName)+
  # +text+ and +tooltip+ default to "Humanized action name"
  #
  # When no block is given, the defaults will be used:
  #
  #     action :my_cool_action
  #
  # is equivalent (unless localization is found for this action) to:
  #
  #     action :my_cool_action do |c|
  #       c.text = c.tooltip = "My cool action"
  #       c.handler = :on_my_cool_action
  #     end
  #
  # == Accessing component configuration from action block
  #
  # Because the action block get transformed into an instance method, it's possible to access the `config` method of the component itself:
  #
  #     action :show_report do |c|
  #       c.text = "Show report"
  #       c.icon = :report
  #       c.disabled = !config[:can_see_report]
  #     end
  #
  # == Overriding an action
  #
  # When extending a component, it's possible to override its actions. You'll need to call the +super+ method passing the configuration object to it in order to get the super-class' action configuration:
  #
  #     action :destroy do |c|
  #       super(c) # original config
  #       c.text = "Destroy (extended)" # overriding the text
  #     end
  #
  # == I18n of actions
  #
  # +text+, +tooltip+ and +icon+ for an action will be picked up from a locale file (if located there) whenever they are not specified in the config.
  # E.g., an action named "some_action" and defined in the component +MyComponents::CoolComponent+, will look for its text in:
  #
  #     I18n.t('my_components.cool_component.actions.some_action.text')
  #
  # for its tooltip in:
  #
  #     I18n.t('my_components.cool_component.actions.some_action.tooltip')
  #
  # and for its icon in:
  #
  #     I18n.t('my_components.cool_component.actions.some_action.icon')
  module Actions
    extend ActiveSupport::Concern

    ACTION_METHOD_NAME = "%s_action"

    included do
      # Returns registered actions
      class_attribute :registered_actions
      self.registered_actions = []
    end

    module ClassMethods
      def action(name, &block)
        self.registered_actions |= [name]

        method_name = ACTION_METHOD_NAME % name

        if block_given?
          define_method(method_name, &block)
        else
          define_method(method_name) do |action_config|
            action_config
          end
        end
      end

      # Must stay public, used from ActionConfig
      # @return [String|nil] full URI to an icon file by its name (provided we have a controller)
      def uri_to_icon(icon)
        Netzke::Core.with_icons ? [(controller && controller.config.relative_url_root), Netzke::Core.icons_uri, '/', icon.to_s, ".png"].join : nil
      end
    end

    # All actions for this instance
    def actions
      @actions ||= self.class.registered_actions.inject({}) do |res, name|
        action_config = Netzke::Core::ActionConfig.new(name, self)
        send(ACTION_METHOD_NAME % name, action_config)
        if action_config.excluded
          res.merge(name.to_sym => {excluded: true})
        else
          res.merge(name.to_sym => action_config)
        end
      end
    end

    def js_configure(c)
      super
      c.actions = actions
    end

  private
    def uri_to_icon(icon)
      self.class.uri_to_icon(icon)
    end
  end
end
