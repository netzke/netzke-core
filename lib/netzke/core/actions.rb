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
  # [+text+]
  #   The text of the action (defaults to humanized action name)
  # [+icon+]
  #   Can be set to either a String (which will be interpreted as a full URI to the icon file), or as a Symbol, which will be expanded to +Netzke::Core.icons_uri+ + "/(icon).png". Defaults to nil (no icon)
  # [+tooltip+]
  #   The tooltip of the action (defaults to humanized action name)
  # [+disabled+]
  #   When set to +true+, renders this action as disabled
  # [+handler+]
  #   A symbol that represents the JavaScript public method (snake-case), which will be called in the scope of the component instance. Defaults to +on_(action_name)+, which on JavaScript side will result in a call to +on(CamelCaseActionName)+
  # [+excluded+]
  #   When set to true, gets the action excluded from menus and toolbars
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
  #
  # == Using actions
  #
  # Actions can be refferred to in the component configuration as symbols. The most common use cases are configuring toolbars.
  # For example, to configure a bottom toolbar to show a button reflecting the +:do_something+ action:
  #
  #     def configure(c)
  #       super
  #       c.bbar = [:do_something]
  #     end
  #
  # Using the +docked_items+ property is also possible:
  #
  #     def configure(c)
  #       super
  #       c.docked_items = [{
  #         xtype: :toolbar,
  #         dock: :left,
  #         items: [:do_something]
  #       }]
  #     end
  #
  # == Interfering with action events in client class
  #
  # For each action Netzke creates an event on the level of the parent component following the convention '<action_name>click'. The handler receives the component itself as a parameter. If the handler returns +false+, the action event is not further propagated.
  module Actions
    extend ActiveSupport::Concern

    included do
      # Declares Base.action, for declaring actions, and Base#actions, which returns a [Hash] of all action configs by name
      declare_dsl_for :actions, config_class: Netzke::Core::ActionConfig
    end

    module ClassMethods
      # Must stay public, used from ActionConfig
      # @return [String|nil] full URI to an icon file by its name (provided we have a controller)
      def uri_to_icon(icon)
        Netzke::Core.with_icons ? [(controller && controller.config.relative_url_root), Netzke::Core.icons_uri, '/', icon.to_s, ".png"].join : nil
      end
    end

    def js_configure(c)
      super
      c.actions = actions
    end

    def extend_item(item)
      super detect_and_normalize_action(item)
    end

  private

    def detect_and_normalize_action(item)
      item = {action: item} if item.is_a?(Symbol) && actions[item]
      if item.is_a?(Hash) && action_name = item[:action]
        cfg = actions[action_name]
        cfg.merge!(item)
        if cfg[:excluded]
          {excluded: true}
        else
          item.merge(netzke_action: cfg[:action])
        end
      else
        item
      end
    end

    def uri_to_icon(icon)
      self.class.uri_to_icon(icon)
    end
  end
end
