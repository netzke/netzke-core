# v0.7 to v0.8 upgrade guide

The main goals of the refactor were:

* Make the API syntax more consistent, and such easier to remember
* Get rid of as much Ruby "magic" as possible
* Provide access to the component class/instance from any declaration (components, actions, endpoints, etc)
* Generally simplify the code

## Actions

### Defining actions

Here are the current 2 ways of defining actions:

    action :destroy do |c|
      c.text = "Destroy!"
      c.tooltip = "Destroying it all"
      c.icon = :delete
    end

    action :my_action # it will use the default (eventually localized) values for text and tooltip

### Overriding actions in inherited classes

Overriding an action, you should make use of the `super` method, passing to it the action config:

    action :destroy do |c|
      super(c) # do the super class` config
      c.text = "Destroy if you dare" # overriding the text
    end

### Referring to actions in toolbars/menus

Symbol#action is no longer defined. Refer to actions in toolbars/menus by simply using symbols:

    def configure(c)
      super
      c.bbar = [:my_action, :destroy]
    end

Referring to actions on the class level will no longer work. Define the toolbars inside the `configure` method.

### I18n of actions

+text+, +tooltip+ and +icon+ for an action will be picked up from a locale file (if located there) whenever they are not specified in the config.
E.g., an action `some_action` defined in the component +MyComponents::CoolComponent+, will look for its text in:

    I18n.t('my_components.cool_component.actions.some_action.text')

for its tooltip in:

    I18n.t('my_components.cool_component.actions.some_action.tooltip')

and for its icon in:

    I18n.t('my_components.cool_component.actions.some_action.icon')

## Child components

### Defining child components

A child component gets defined with the `component` method, which now accepts a block with a parameter:

    component :east_center_panel do |c|
      c.klass = SimpleComponent
      c.title = "A panel"
      c.border = false
    end

Child component's class is now specified as the `klass` option and is actually a *Class*, not a String. When no `klass` or no block is given, the component's class will be derived from its name, e.g.:

    component :simple_component

(component's class will be SimpleComponent)

Defining a component in a class gives an advantage of accessing the `config` method of the parent component and decide upon child component's configuration based on that, e.g.:

    component :east_center_panel do |c|
      c.klass = SimpleComponent
      c.title = config.east_center_panel_title
    end

### Overriding child components

Overriding a component, you should make use of the `super` method, passing to it the component config:

    component :simple_component do |c|
      super(c) # do the super class` config
      c.klass = LessSimpleComponent # use a different class
    end

### Lazy loaded components

All child components now by default are marked as lazy loaded, unless they are referred in the layout (see the **Layout (items)** section). You can override this behavior by setting `eager_loading` to `true`.

## Layout (items)

### Referring to Netzke components in items

You should define the component's layout in the `items` property in component's config. You can refer to child components by specifying the `netzke_component` key:

    def configure(c)
      super

      c.items = [
        { xtype: :panel, title: "Simple Ext panel" },
        { netzke_component: :some_child_component, title: "a netzke component" }
      ]
    end

In this case, the component `some_child_component` should be defined with the `component` method.

When no additional layout configuration is needed for a component, you can refer to them simply as symbols:

    component :tab_one
    component :tab_two

    def configure(c)
      super
      c.items = [ :tab_one, :tab_two ]
    end

### Implicit components in items

Previously there was a way to specify a component class directly in items (by using the `class_name` option), which would implicitly define a child component. This is no longer possible. The layout can now only refer to explicitly defined components.

### Specifying items in config

It is possible to specify the items in the config in the same format as it is done in the `items` method. If `config.items` is provided, it takes precedence over the `items` method. This can be useful for modifying the default layout of a child component by means of configuring it.

It's advised to override the `items` method when a component needs to define it's layout, and not use the `configure` method for that (see the **Self-configuration** section).

## Self-configuration

### The `configure` method

The `configure` method should be used to override the Ruby-side component configuration.

In case when a newly created component needs to change configuration values for its instance, it should define the `configure` method and make use of the component's global `config` method (which is an instance of `ActiveSupport::OrderedOptions`):

    def configure(c)
      super # let the base class do its work, e.g. set the `config` instance with the config values passed by this component's user
      c.title = c.title + "(read-only)" if c.mode == :read_only
    end

There's no more need for `default_config` or any other `*_config` methods, and they should be replaced with `configure`.

The `configure` method is useful for (dynamically) defining toolbars, titles, and other properties of a component's instance.

### The `js_configure` method

The `js_configure' method should be used to override the JS-side component configuration. It is called by the framework when the configuration for the JS instantiating of the component should be retrieved. Thus, it's *not* being called when a component is being instantiated to process an endpoint call.

Override it when you need to extend/modify the config for the JS component intance.

### DSL-delegated methods are gone

No more `title` and `items` are defined as DSL methods. Include `Netzke::ConfigToDslDelegator` and use `delegate_to_dsl` method if you need that functionality in a component.
Thus, `Netzke::ConfigToDslDelegator` is not included in Netzke::Base anymore.
