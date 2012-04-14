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

### Redefining actions in child classes

You should define a method called `<action_name>_action`:

    def destroy_action(a)
      super # to get what was defined in the super class
      a.text = "Destroy if you dare" # overriding the text
    end

### Referring to actions in toolbars/menus

Symbol#action is no longer defined. Refer to actions in toolbars/menus by simply using symbols:

    js_propety :bbar, [:my_action, :destroy]
