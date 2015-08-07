# v0.12.3 - WIP
* Get rid of Ext's viewport warning
* Uglify components' JS when not in the test/development env
* Fix stack-overflow issue in certain cases
* Implement inline nesting of components
* xtype of Netzke components receives additional "netzke" prefix (can potentially break things if you explicitely refer to xtypes)

# v0.12.2 - 2015-06-06
* Fix loading multi-instance components

# v0.12.1 - 2015-05-31

* Add `Base#client_config` shortcut to `config.client_config`, make it ActiveSupport::OrderedOptions
* Rename `clientConfig` to `netzkeClientConfig` on client

# v0.12.0 - 2015-03-16

* ExtJS 5.1
* More reliable implementation of netzkeGetParentComponent()
* Callback passed to netzkeLoadComponent() will receive a second parameter with config object passed to netzkeLoadComponent()

# v0.11.0 - 2015-02-05

* Rails 4.2

# v0.10.1 - 2014-05-24

* Fix an IE8 issue (@AlexKovynev)
* Fix issue with multi-instance loading

# v0.10.0 - 2014-04-02

* Rails 4

# v0.9.0 - 2014-02-08
* Introduce `Base#validate_config` that can be overridden to validate a component's configuration
* Fix icon detection
* Back to Rails 3 (use 0.10.x with Rails 4)

# v0.9.0.rc1 - 2013-12-01
* Rails 4
* Ext JS 4.2
* Ext JS Neptune scheme is default

# v0.8.4 - 2013-05-22
* bug fix
  * Re-enable session expiration detection
  * Do not crash on a rare situation when an endpoint is being called on an non-existing child component
* improvements
  * Add `serverexception` event on `Netzke.directProvider`, subscribe to it to handle server exceptions
  * Endpoint calls will now pass Ext.direct.Exception to the provided callback function in case of server exception
  * A component will clean-up the loading mask when a server exception occurs during dynamic component loading
  * `netzkeFeedback` now shows multiple messages in a single slide banner
  * Implement multi-instance child component loading with different configuration (see MultiInstanceLoading in the test app)

# v0.8.3 - 2013-03-22
* support Rails 3.2.13

# v0.8.2 - 2013-03-12
* bug fix
  * RuntimeError "can't add a new key into hash during iteration" in Composition in some scenarious (thanks @wupdiwup)
  * netzkeReload works again

* improvements
  * minimize core Ruby class extensions
  * tests can now be run by simply executing `rake` from the gem's root (thanks @allomov)
  * feedback delay is now globally configurable
  * netzkeFeedback now understands {delay: seconds} as second parameter
  * add support for arbitrary controllers replacing NetzkeController
  * add support for HAML templates
  * some code refactoring
  * tests are rewritten with Mocha.js and CoffeeScript

# v0.8.1 - 2012-12-15
* bug fix
  * in production, JS comment stripping could cause modification of form_authenticity_token (issue #43) (thanks @scho)

# v0.8.0 - 2012-12-09
## Misc
  * many backward-incompatible API changes, see below
  * major code clean-up and refactor
  * introduce `Netzke::Core::Panel` - a simple panel with defaults, that can be immediately rendered
  * Netzke child components can now be referred anywhere (e.g. dockedItems), not only in items
  * drop support for Ruby 1.8.7
  * rename `netzke_init` view helper method to `load_netzke`
  * `before_load` is gone; if necessary, do preload stuff in the overridden `Base#js_configure`
  * rename `global_id` to `js_id`
  * `load_nezke` (previously `netzke_init`) now understands the `minified` option
  * implement referring to config methods declared in JavaScript from Ruby by using :symbols (see `Netzke::Base`)
  * i18n of actions takes into account ancestor classes
  * child component and action config now understand `excluded` option (handy for authorization)
  * `Base#update_state` and `#clear_state` are gone. Use `state` directly.

## Component self-configuration

Often when extending an existing component (e.g. from `Netzke::Basepack`), there's a need to tune its behaviour by modifying its configuration. There are 2 methods that can be overridden in order to achieve that: `Base#configure` and `Base#js_configure`. The former is used to configure a component as whole. The latter - exclusively the component's JavaScript class instance. `js_configure` is being called only when the component is being rendered in the browser, and not when a component is instantiated, for example, for invoking its endpoint.

Both methods receive as the only argument a `ActiveSupport::OrderedOptions`, which allows for syntax like this:

    def configure(c)
      c.some_config_option = 42
      c.merge!(option_one: 1, option_two: 2)
      super
    end

Calling `super` is essential for the super-component to do its own configuration (for example, `Netzke::Base#configure` would mix in the passed config options).

The `Base#default_config` method and any other `Base#*_config` methods are gone and should be replaced with `Base#configure` or `Base#js_configure` - depending on the goal.

### Base#configure

The `configure` method must be used to override the configuration of a component as whole (influencing component's both Ruby and JavaScript behaviour). For example, if the super component implements the `persistence` option, we may want to enable it in our component like this:

    def configure(c)
      c.persistence = true
      super
    end

The place to call `super` is important. In the provided example, the `persistence` option can be overridden by this component's user. However, if we put it after `super`, it will override the user's setting. Another example of overriding a user's setting might be, for example, extending a component bottom bar depending on the `mode` config:

    def configure(c)
      super
      c.bbar = [*c.bbar, '-', :admin] if c.mode == :admin
    end

The `configure` method is useful for (dynamically) defining toolbars, titles, and other properties of a component's instance.

### Access to component's config

The result of `Base#configure` can be accessed through `Base#config` method from anywhere in the class.

### Base#js_configure

The `js_configure' method should be used to override the JS-side component configuration. It is called by the framework when the configuration for the JS instantiating of the component should be retrieved. Thus, it's *not* being called when a component is being instantiated to process an endpoint call. Override it when you need to extend/modify the config for the JS component intance.

The execution of `js_configure` does not influence the content of the `Base#config` method.

## JavaScript class configuration

The following DSL methods are gone: `js_include`, `js_mixin`, `js_base_class`, `js_method`, `js_property`, `js_properties`. Instead, use the `js_configure` class method (not to be confused with the previously mentioned *intstance* method `Base#js_configure`):

    class MyComponent < Netzke::Base
      js_configure do |c|
        c.mixin                     # replaces js_mixin preserving the signature
        c.require                   # replaces js_include preserving the signature
        c.extend = "Ext.tab.Panel"  # replaces js_base_class

        c.title = "My Component"    # use instead of js_property :title, "My Component"

        c.on_my_action = <<-JS      # use instead of js_method :on_my_action, ...
          function(){
            // ...
          }
        JS
      end

      # ...
    end

As you see, assignement must be used to define the JS class's properties, including functions.

## Actions

The `action` DSL method does not accept a hash as an optional second parameter any longer, but rather a block, which receives a configuration object:

    action :destroy do |c|
      c.text = "Destroy!"
      c.tooltip = "Destroying it all"
      c.icon = :delete
    end

The following is still valid:

    action :my_action # it will use default (eventually localized) values for text and tooltip

### Overriding actions in inherited classes

Overriding an action while extending a component is possible by using the same `acton` method. To receive the action config from the superclass, use the `super` method, passing to it the block parameter:

    action :destroy do |c|
      super(c) # do the config from the superclass
      c.text = "Destroy if you dare" # overriding the text
    end

### Referring to actions in toolbars/menus

`Symbol#action` is no longer defined. Refer to actions in toolbars/menus by simply using symbols:

    def configure(c)
      super
      c.bbar = [:my_action, :destroy]
    end

Another way (useful when re-configuring the toolbars of a child component) is by using hashes that have the `netzke_action` key:

    def configure(c)
      super

      c.bbar = [
        { netzke_action: :my_action, title: "My cool action" },
        { netzke_action: :destroy, title: "Destroy!" }
      ]
    end

Referring to actions on the class level (e.g. with `js_property :bbar`) will no longer work. Define the toolbars inside the `configure` method.

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

A child component gets defined with the `component` method receiving a block:

    component :east_center_panel do |c|
      c.klass = SimpleComponent
      c.title = "A panel"
      c.border = false
    end

Child component's class is now specified as the `klass` option and is actually a Class, not a String. When no `klass` or no block is given, the component's class will be derived from its name, e.g.:

    component :simple_component

is equivalent to:

    component :simple_component do |c|
      c.klass = SimpleComponent
    end

Defining a component in a block gives an advantage of accessing the `config` method of the parent component, e.g.:

    component :east_center_panel do |c|
      c.klass = SimpleComponent
      c.title = config.east_center_panel_title # something that could be passed as a config option to the parent component
    end

If no `klass` is specified, `Netzke::Core::Panel` is assumed.

### Overriding child components

Overriding a child component while extending a component is possible by using the same `component` method. To receive the child component config from the superclass, use the `super` method, passing to it the block parameter:

    component :simple_component do |c|
      super(c) # do the config from the superclass
      c.klass = LessSimpleComponent # use a different class
    end

### Lazy vs eager component loading

All child components now by default are being lazily loaded on request from the parent, unless they are referred in the layout (see the **Layout** section). You can override this behavior by setting `eager_loading` to `true`, so that the child component's config and class are instantly available at the parent.

## Layout

### Referring to Netzke components

The `Symbol#component` method is no longer defined. The preferred way of referring to child components in (docked) items is by using symbols:

    # provided child_one and child_two components are defined in the class
    def configure(c)
      super

      c.items = [:child_one, :child_two]
    end

Another way (useful when re-configuring the layout of a child component) is by using hashes that have the `component` key:

    def configure(c)
      super

      c.items = [
        { xtype: :panel, title: "Simple Ext panel" },
        { component: :child_one, title: "First child" },
        { component: :child_two, title: "Second child" }
      ]
    end

### Implicitly defined components in items

Previously there was a way to specify a component class directly in items (by using the `class_name` option), which would implicitly define a child component. This is no longer possible. The layout can now only refer to explicitly defined components.

### Specifying items in config

It is possible to specify the items in the config in the same format as it is done in the `items` method. If `config.items` is provided, it takes precedence over the `items` method. This can be useful for modifying the default layout of a child component by means of configuring it.

It's advised to override the `items` method when a component needs to define it's layout, and not use the `configure` method for that (see the **Self-configuration** section).

### DSL-delegated methods are gone

No more `title` and `items` are defined as DSL methods. Include `Netzke::ConfigToDslDelegator` and use `delegate_to_dsl` method if you need that functionality in a component.
Thus, `Netzke::ConfigToDslDelegator` is not included in Netzke::Base anymore.

## Defining client class

Client class (JavaScript part of the component) has been refactored.

### Methods renamed

The following public method name changes took place for the sake of consistence:

* localId => netzkeLocalId
* setResult => netzkeSetResult
* endpointUrl => netzkeEndpointUrl
* loadNetzkeComponent => netzkeLoadComponent (signature changed, see "javascripts/ext.js")
* componentDelivered => netzkeComponentDelivered
* componentDeliveryFailed => netzkeComponentDeliveryFailed
* getParentNetzkeComponent => netzkeGetParentComponent
* reload => netzkeReload
* instantiateChildNetzkeComponent => netzkeInstantiateComponent
* getChildNetzkeComponent => netzkeGetComponent

# v0.7.7 - 2012-10-21
* Ext JS required version bump (4.1.x)

# v0.7.6 - 2012-07-27
* Rails 3.2

# v0.7.5 - 2012-03-05
* API changes
  * The `:class_name` option must *always* include the full class name now. So, `Basepack::GridPanel` won't work, instead do `Netzke::Basepack::GridPanel`

* enhancements
  * Set default Ext.Direct retry attempts to 0, as more than 0 may only be needed in special cases.

# v0.7.4 - 2011-10-20
* enhancements
  * Less aggressive rescuing at constantizing a string, to let more descriptive exceptions get through.
  * New `delegates_to_dsl` class method to degelate default config options to class level. See the `ConfigToDslDelegator` module.

# v0.7.3 - 2011-09-04
* Rails 3.1 compatibility. Really. Hopefully.

# v0.7.2 - 2011-08-31
* Rails 3.1
* bug fix
  * When a component is dynamically loaded in a container, the load mask is now limited to that container
* enhancements
  * New u config option for loadNetzkeComponent, which prevents emptying the container when inserting the newly loaded component; can be used for loading components into layouts different from 'fit'

# v0.7.1 - 2011-08-17
* bug fix
  * Multiple compound Netzke components in the same Rails view were causing JS errors

# v0.7.0 - 2011-08-09
* Ext JS 4 compatibility

* API changes
  * New `ext_uri` config option (defaults to "extjs") - relative URI to the Ext JS library on the server.
  * New `ext3_compat_uri` config option (defaults to `nil`) - relative URI to the Ext 3 compatibility layer. When nil, no compatibility layer is loaded.
  * New `current_user_method` config option (defaults to :current_user) to let Netzke::Core know which method to call on Rails controller to retrieve the current user.
  * New `Netzke::Core.current_user` method to retrieve the current user.
  * Passing instructions from server back to the client now is only meant for single-argument methods on client; arrays are not expanded into arguments any longer.
  * New `instantiateChildNetzkeComponent` method to instantiate a Netzke component by name.
  * Default component height (400) and border (false) are no longer set.

* broken API
  * The `ext_location` config option renamed to `ext_path`
  * loadNetzkeComponent (ex loadComponent) won't automatically show a component with xtype 'window' any longer; use the callback to do  that manually

* enhancements
  * `js_mixin` without parameters will assume :component_class_name_underscored
  * Ext locale file is automatically included when I18n.locale is not :en
  * Child components now have `itemId` set to component's name, so that `getComponent(component_name)` can be used to retrieve immediate child components
  * `loadNetzkeComponent` that should be used instead of loadComponent won't render the loaded component unless the container is specified (which can be an id or an instance)
  * JS: `componentDeliveryFailed` method added that is called by the `deliver_component` endpoint

* bug fix
  * Tolerate relative_url_root when calculating the URI to icons in actions

* deprecations
  * instantiateAndRenderComponent
  * getParent in favor of getParentNetzkeComponent
  * getChildComponent in favor of getChildNetzkeComponent
  * loadComponent in favor of loadNetzkeComponent
  * feedback in favor of netzkeFeedback
  * Ext.container.Container#instantiateChild should not be used

# v0.6.7 - 2011-08-16
* enhancements
  * No more using `method_missing` for invoking endpoints.
  * New "cache" option for `netzke_init` which gets passed to `javascript_include_tag` (no support for css caching of this type yet)
  * Netzke dynamic js and css-files such as ext.js, touch.css, now get generated at the application start, and put into "public/netzke". Solves a long standing problem with serving those files by HTTP servers in some cases. Enables caching naturally.
  * Moved features and specs to test/core_test_app (tests should be run from that folder from now on)
  * Introduced plugin functionality. We can create Netzke components that are pluggable into other components as Ext JS plugins.

# v0.6.6 - 2011-02-26
* enhancements
  * Client-server communication is updated to use Ext.Direct (many thanks to @pschyska)
  * Introduced `js_translate` class method that allows specifying i18n properties used in the JavaScript class
  * Better handling of actions i18n
  * New `Netzke::Base.class_config_option` method to specify a class-level configuration options for a component, e.g. (in GridPanel): `class_config_option :column_filters_available, true`. This option then can be set in Rails application configuration, e.g.: `config.netzke.basepack.grid_panel.column_filters_available = false`, or directly on `Netzke::Core.config`, e.g.: `Netzke::Core.config.netzke.basepack.grid_panel.column_filters_available = false`.

# v0.6.5 - 2011-01-14
* enhancements
  * Various fixes for IE
  * Support for Sencha Touch
  * An endpoint can now "call" JavaScript functions that accept multiple parameters, by specifying an array, e.g.:
      {:some_js_function => [arg1, arg2]}
  * New API: `js_mixin` method to "mixin" JavaScript objects from external files (see RDocs).
  * New JS class `componentLoadMask` property to configure a mask when a component gets dynamically loaded with `loadComponent`. Accepts the same configuration as Ext.LoadMask.
  * `js_include` and `css_include` accept both symbols and strings, where strings would contain full paths to the included file, whereas symbols get expanded to full paths following simple conventions (see RDocs for details).
  * Make some of `Netzke::Core` setup happen earlier in the loading process, so that we can safely use it while defining components.
  * Performance improvements by memoizing `Base.constantize_class_name`.
  * I18n for actions, see `Netzke::Actions`.

* bug fix
  * The "componentload" event now gets fired after a component is dynamically loaded. The handler receives the instance of the loaded component.
  * Feedback does not insert a new div every time being called
  * JS class caching was broken for name-scoped classes
  * When a component was dynamically loaded into a hidden container, it wasn't shown when the container got shown next time

# v0.6.4 - 2010-11-05
* enhancements
  * Implemented Netzke.isLoading(), useful for testing
  * Persistence support

* API change
  * `endpoint` DSL call now results in a method called <endpoint_name>_endpoint, _not_ just <endpoint_name> (beware when overriding endpoint definitions, or calling endpoint methods on child components)
  * Using `api` for endpoint declaration is gone

# v0.6.3 - 2010-11-02
* The `ext_config` option is back, deprecated.

# v0.6.2 - 2010-10-27
* Introduced the Symbol#component method to declare components in the config (instead of now deprecated js_component).

# v0.6.1 - 2010-10-26
* Disabled buggy implementation of rendering on-page JS classes in netzke.js instead of main page.

# v0.6.0 - 2010-10-24
* Rails3 compatibility, thorough rewrite
* Much more thorough testing

* API backward incompatibility
  * `ext_config` config level is removed; put all that configuration in the top level
  * mentioning actions in the `bbar`, `tbar`, etc, should be explicit, e.g.:

      :bbar => [:apply.action, :delete.action]

  * `late_aggregatee` is now `lazy_loading`
  * `aggregatees` are now `components`
  * `widgets` are now `components`, too
  * `api` is now `endpoint`
  * `persistent_config_enabled?` is now `persistence_enabled?`
  * Using the `js_extend_properties` class method in your components in deprecated (and maybe even broken). Use `js_property` (or `js_properties`) and `js_method` instead (see multiple examples in test/core_test_app)
  * the `load_component_with_cache` endpoint renamed to `deliver_component`

* New
  * `ext` helper in the views to embed any (pure) Ext component into a view
  * `component` DSL method to declare child components
  * `config` DSL method to set the configuration of an instance
  * `action` DSL method to configure actions
  * `js_method` DSL method to define (public) methods in JS class
  * `js_property` DSL method to define (public) properties in JS class
  * `endpoint` DSL method to define server endpoints

* Different deprecations throughout the code

# v0.5.3 - 2010-06-14
* Fix: Getting rid of deprecation warnings about tasks not sitting in lib.

# v0.5.2 - 2010-06-11
* Ext 3.2.1
* Fix: Netzke::Base.before_load is now also called for the widgets embedded directly into a view.
* New: support for external stylesheets.
* Fix: the "value" column type has been changed to text to prevent migration problems is some cases
* New: global_persistent_config method allows accessing persistent storage with no owner (widget) assigned
* New: any widget can now implement <tt>before_api_call</tt> interceptor. If it returns anything but empty hash, it'll be used as the result of *any* API call to this widget. The interceptor receives as parameter the name of the API call issued and the arguments. Use it to implement authorization.
* Fix: got the Ext's state provider out of the way (thank you for all the confusion)

# v0.5.1 - 2010-02-26
* Compatibility with Ext 3.1.1
* New: <tt>Netzke.page</tt> object now contains all the widgets declared on the page
* Code: replaced (references to) deprecated function names

# v0.5.0 - 2010-01-10
* Compatibility with Ext 3.1.0
* API change: Netzke widget's now should be declared directly in the views instead of controllers.
* API change: all ExtJS and Netzke JavaScript and styles are now loaded with the help of <tt>netzke_init</tt> helper.
* API change: <tt>persistence_key</tt> option replaces <tt>persistent_config_id</tt> option.
* Impr: headers in panels in the "config" mode now show the widget's global ID.
* New: required ExtJS version check introduced at initial Netzke load.
* Depr: :widget_class_name option is deprecated, use :class_name.
* DRY: now there's no need to always define "actions" method, use it to override the defaults, which are automatically calculated based on configuration for toolbars/menu.
* Impr: each generated JS class now has its unique xtype, e.g. "netzkegridpanel".
* Fix: FeedbackGhost moved over from netzke-basepack.

# v0.4.5.2 - 2009-11-09
* Fix: Hash#convert_keys and Array#convert_keys in core extensions are now renamed into deep_convert_keys, and now always plainly do what they're expected to do: recursively convert keys according to given block.

# v0.4.5.1 - 2009-11-09
* Regression: fixing inheritance and caching.
* FeedbackGhost is too simple to be a Netzke widget (having no server part), so, moved to static JavaScript.

# v0.4.5 - 2009-11-08
* API change: Netzke::Base: <tt>id_name</tt> accessor renamed to <tt>global_id</tt>
* Code: several internal code changes
* Code: lightly better test coverage
* New: <tt>Netzke::Base#global_id_by_reference</tt> method
* Compatibility: resolving conflicts with the <tt>api</tt> property in some Ext v3.0 components
* Fix: <tt>deliver_component</tt> was throwing exception when the requested component wasn't defined
* New: <tt>persistent_config_id</tt> configuration option allows specifying an id by which persistent configuration is identified for the widget. Handy if different homogeneous widgets need to share the same persistent configuration.
* New: <tt>Netzke::Base#persistent_config</tt> method now accepts an optional boolean parameter signalizing that the configuration is global (not bound to a widget)
* Impr: cleaner handling of actions and toolbars; fbar configuration introduced.
* Impr: calling an API method now provides for the result value (if return by the server) in the callback.
* Impr: allows name spaced creation of Netzke widgets, e.g. widgets can now be defined under any module under Netzke, not only *directly* under Netzke.
* New: support for Ext.Window-based widgets (it'll call show() on them when the "*_widget_render" helper is used).

# v0.4.4 - 2009-10-12
* API change: default handlers for actions and tools are now supposed to be prefixed with "on". E.g.: if you declare an action named <tt>clear_table</tt>, the handler must be called (in Ruby) <tt>on_clear_table</tt> (mapped to <tt>onClearTable</tt> in JavaScript).
* Internal: the JavaScript instance now knows if persistent config is enabled (by checking this.persistentConfig).
* Fix: solving the "Node cannot be inserted at the specified point in the hierarchy" problem by being more strict with duplicated IDs for elements on the same page.
* Fix: Ext 3.0 compatibility.
* Impr: <tt>getChildComponent</tt> now allows referring to a widget like this: "parent__parent__some_widget__some_nested_widget"

# v0.4.3
* Fix: reworking loadComponent()-related code, closing a security flaw when a malicious browser could send any configuration options to instantiate the widget being loaded.

# v0.4.2 - 2009-09-11
* Fix: the API call (at the JavaScript side) was ignoring the callback parameter.
* Impr: if the array of API points is empty, it's not added into js_config anymore.
* New: new testing widgets in netzke_controller.
* Fix: extra CSS includes now take effect.
* New: Support for masquerading as "World". In this mode all the "touched" persistent preferences will be overwritten for all roles and users.

# v0.4.1 - 2009-09-06
* Version bumb to force github rebuild the gem (Manifest is now included)

# v0.4.0 - 2009-09-05
* Major refactoring.

# v0.3.2 - 2009-06-05
* Netzke doesn't overwrite session[:user] anymore to not cause authentication-related problems.

# v0.3.1 - 2009-05-07
* Fix: persistent_config_manager can now be set to nil, and it will work fine

# v0.3.0 - 2009-05-07
* Refactor: got rid of NetzkeLayout model, now all layouts are stored in netzke_preferences
* New: persistent_config now has a method for_widget that accepts a block
* autotest compatibility
* New: String#to_b converts a string to true/false
* New: Netzke::Base.session introduced for session data
* New: weak_children_config and strong_children_config can now be declared by a widget, which specifies weak and strong configuration that every child of this widget will receive (e.g. display/hide configuration tool)
* Fix: (degradation) flash message is now shown again in case of erroneous attempt to load a widge
* New: widgets now can check session[:netzke_just_logged_in] and session[:netzke_just_logged_out] automatically set by Netzke after login/logout

# v0.2.11
* Introduction of getOwnerComponent()-method to Ext.Component. It provides the Netzke widget this Component belongs to.

# v0.2.10
* Removed dependency on 'json' gem.
* Rails v2.3.2 compatibility.

# v0.2.9
* Actions, toolbars and tools reworked for easier configuration.
* Menus introduced (based on actions).
* Significant code clean-up.
* Bug fix (nasty one): Ext.widgetMixIn was getting messed up along with dynamic widget loading.
* Must work in IE now.

# v0.2.8
* Support for extra javascripts and stylesheets per widget.

# v0.2.7
* QuickTips get initialized now, as otherwise Ext 2.2.1 doesn't properly destroy() BoxComponents for me.

# v0.2.6
* FeedackGhost is now capable of displaying multiple flash messages.
* Dependencies slightly refactored.
* An informative exception added to Base#component_instance.
* JS-level inheritance enabled.
* Work-around for the problem with Ext 2.2.1 in loadComponent.
* Events "<action_id>click" added to the widgets along with the actions.
* component_missing method added to Netzke::Base - called when a non-existing aggregate of a widget is tried to be invoked
* Code readability improvements.

# v0.2.5
* Minor code restructuring.

# v0.2.4
* Some minor improvements.

# v0.2.3
* FeedbackGhost will show the feedback on the top of the screen independent of the page scrolling.
* Ext.Panel#loadComponent will accept null as url to delete the currently loaded widget
* Bug fix: persistent_config works again

# v0.2.2
* js_ext_config instance method added for overwriting
* Multiuser support
* Using Rails.logger for logging
* "config"-class method for every class inheriting Netzke::Base - for class-level configurations

# v0.2.1
* Fixed the path to ext-base-min.js for production mode.
* Also works in Safari now.

# v0.2.0
* Some re-factoring and redesign. Now simple compound widgets can be created on the fly in the controller
* Added ext_widget[:quiet] configuration option to suppress widget's feedback
* Support for extra CSS sources, similar to JS
* NETZKE_BOOT_CONFIG introduced to specify which Netzke functionality should be disabled to reduce the size of /netzke/netzke.[js|css]
* FeedbackGhost widget added - invisible widget providing feedback to the user
* netzke_widget controller class-method renamed into netzke
* JS-comments now get stripped also from the extra files that get included in the netzke-* gems.
* Permissions joined js_config
* Bug fixes

# v0.1.4
* Helpers added to facilitate ExtJS/netzke.js inclusion
* The route defined for netzke_controller
* netzke.html.erb-layout is not needed anymore, so not produced by the generator
* Now compliant with Rails' forgery protection

# v0.1.3
* Generators fixed

# v0.1.2
* Fixed the bug with <widget>_class_definition returning empty string on sequential loading.

# v0.1.1.1
* Meta: moving from GitHub to RubyForge

# v0.1.1
* Inter-widget dependencies code reworked
* JS-class code generation code slightly reworked

# v0.1.0.2
* Meta: fix outdated Manifest

# v0.1.0.1
* Meta work: replacing underscore with dash in the name

# v0.1.0 - 2008-12-11
* Initial release
