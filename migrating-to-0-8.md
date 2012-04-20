# v0.7 to v0.8 migration guide

## Actions

### Defining actions

Here are the current ways of defining actions:

    action :destroy do |a|
      a.text = "Destroy!"
      a.tooltip = "Destroying it all"
      a.icon = :delete
    end

    action :my_action # it will use the default (eventually localized) values for text and tooltip

### Overriding actions in inherited classes

You should define a method called `<action_name>_action`:

    def destroy_action(a)
      super # to get what was defined in the super class
      a.text = "Destroy if you dare" # overriding the text
    end

### Referring to actions in toolbars/menus

Symbol#action is no longer defined. Refer to actions in toolbars/menus by simply using symbols:

    js_propety :bbar, [:my_action, :destroy]

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

Previously there was a way to specify a component class directly in items, which would implicitely create a child component. This is no longer possible. The layout can now only refer to explicitely defined components.

### Specifying items in config

It is possible to specify the items in the config in the same format as it is done in the "items" method. If config.items is provided, it takes precedence over the `items` method. This can be useful for modifying the default layout of a child component by means of configuring it.
