# v0.7 to v0.8 upgrade guide

## Actions

### Defining actions

Here are the current 2 ways of defining actions:

    action :destroy do |a|
      a.text = "Destroy!"
      a.tooltip = "Destroying it all"
      a.icon = :delete
    end

    action :my_action # it will use the default (eventually localized) values for text and tooltip

### Overriding actions in inherited classes

In order to override an action, you should define a method called `<action_name>_action`:

    def destroy_action(a)
      super # to get what was defined in the super class
      a.text = "Destroy if you dare" # overriding the text
    end

### Referring to actions in toolbars/menus

Symbol#action is no longer defined. Refer to actions in toolbars/menus by simply using symbols:

    def configure
      super
      config.bbar = [:my_action, :destroy]
    end

Referring to actions on the class level with `js_property` or `js_properties` will no longer work. Define the toolbars inside the `configure` method.

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

In order to override a component, you should define a method called `<components_name>_component`:

    def simple_component_component(c)
      super # to get superclass' config
      c.klass = LessSimpleComponent # use a different class
    end

### Lazy loaded components

All child components now by default are marked as lazy loaded, unless they are referred in the layout (see the **Layout (items)** section). You can override this behavior by setting `lazy_loading` to `false`.

## Layout (items)

### Referring to Netzke components in items

You should define the component's layout in the items method that should return an array. You can refer to child components by specifying the `netzke_component` key:

    def items
      [
        { xtype: :panel, title: "Simple Ext panel" },
        { netzke_component: :some_child_component, title: "a netzke component" }
      ]
    end

In this case, the component `some_child_component` should be defined with the `component` method.

Previously there was a way to specify a component class directly in items (by using the `class_name` option), which would implicitly define a child component. This is no longer possible. The layout can now only refer to explicitly defined components.

When no additional layout configuration is needed for a component, you can refer to them simply as symbols:

    component :tab_one
    component :tab_two

    def items
      [ :tab_one, :tab_two ]
    end

### Specifying items in config

It is possible to specify the items in the config in the same format as it is done in the "items" method. If config.items is provided, it takes precedence over the `items` method. This can be useful for modifying the default layout of a child component by means of configuring it.

It's advised to override the `items` method when a component needs to define it's layout, and not use the `configure` method for that (see the **Self-configuration** section).

## Self-configuration

### The `configure` method

In case when a newly created component needs to change configuration values for its instance, it should define the `configure` method and make use of the component's global `config` method (which is an instance of ActiveSupport::OrderedOptions):

    def configure
      super # let the base class do its work, e.g. set the `config` instance with the config values passed by this component's user
      config.title = config.title + "(read-only)" if config.mode == :read_only
    end

There's no more need for `default_config` or any other `*_config` methods, and they should be replaced with `configure`.

The `configure` method is useful for defining (default) toolbars, titles, and other properties of a component.
