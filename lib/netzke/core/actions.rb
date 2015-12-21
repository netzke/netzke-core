module Netzke::Core
  # Netzke components provide for convenient configuration of Ext JS actions from the Ruby class.
  #
  # == Defining actions
  #
  # An action is defined with the +action+ class method that accepts a block:
  #
  #     action :destroy do |c|
  #       c.text = "Destroy!"
  #       c.tooltip = "Destroying it all"
  #       c.icon = :delete
  #       c.handler = :destroy_something # `this.destroySomething` will be called on client side
  #     end
  #
  # All config settings for an action are optional. When omitted, the locale files will be consulted first (see "I18n of actions"), falling back to the defaults.
  #
  # [text]
  #   The text of the action (defaults to localized action text, see on I18n below)
  #
  # [icon]
  #   Can be set to either a String (which will be interpreted as a full URI to the icon file), or as a Symbol, which will be expanded to +Netzke::Core.icons_uri+ + "/(icon).png". Defaults to localized action icon (see on I18n below) or nil (no icon)
  #
  # [tooltip]
  #   The tooltip of the action (defaults to localized action tooltip, see on I18n below)
  #
  # [disabled]
  #   When set to +true+, renders this action as disabled
  #
  # [handler]
  #   A symbol that represents the JavaScript public method (snake-cased), which will be called in the scope of the component instance. Defaults to +handle_{action_name}+, which on JavaScript side will result in a call to +handle{ActionName}+
  #
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
  #       c.handler = :handle_my_cool_action
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
  # For each action Netzke creates an event on the level of the parent component following the convention `<action_name>click`. The handler receives the component itself as a parameter. If the handler returns +false+, the action event is not further propagated.
  #
  # == Preventing name clashing with child components
  #
  # If a component has an action and a child component defined with the same name, referring to them by symbols in the
  # configuration will result in a name clash. See {Core::Composition} on how to address that.
  module Actions
    extend ActiveSupport::Concern

    included do
      class_attribute :_declared_actions
      self._declared_actions = []
    end

    module ClassMethods
      # Declares an action
      def action(*args, &block)
        args.each{|name| action(name)} if args.length > 1

        name = args.first

        define_method :"#{name}_action", &(block || ->(c){c})
        # NOTE: "<<" won't work here as this will mutate the array shared between classes
        self._declared_actions += [name]
      end

      # @return [String|nil] full URI to an icon file by its name (provided we have a controller)
      # NOTE: must stay public, used from ActionConfig
      def uri_to_icon(icon)
        Netzke::Core.with_icons ? [(controller && controller.config.relative_url_root), Netzke::Core.icons_uri, '/', icon.to_s, ".png"].join : nil
      end
    end

    def actions
      return @actions if @actions

      @actions = {}.tap do |res|
        self.class._declared_actions.each do |name|
          cfg = Netzke::Core::ActionConfig.new(name, self)
          send("#{name}_action", cfg)
          cfg.set_defaults!
          res[name.to_sym] = cfg.excluded ? {excluded: true} : cfg
        end
      end
    end

    def configure_client(c)
      super
      c.actions = actions
    end

    def extend_item(item)
      super detect_and_normalize_action(item)
    end

  private

    def detect_and_normalize_action(item)
      item = {action: item} if item.is_a?(Symbol) && actions[item]

      if action_name = action_name_if_action(item)
        action_config = actions[action_name]
        if action_config[:excluded]
          {excluded: true}
        else
          {action: action_name.to_s.camelize(:lower)}
        end
      else
        item
      end
    end

    def action_name_if_action(item)
      item.is_a?(Hash) && item[:action]
    end

    def uri_to_icon(icon)
      self.class.uri_to_icon(icon)
    end
  end
end
