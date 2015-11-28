### New stuff

* Routing

### Backward incompatible changes

*   Experimental support for HAML removed

*   A component's subfolders for client-class scripts and stylesheets have been consolidated from
    `javascripts`/`stylesheets` into `client`

*   `Base.css_configure` has been renamed to `Base.client_styles`.

*   `Base.js_configure` has been renamed to `Base.client_class`. There's also no longer need to call
    it to include the default mixin (which is now `<component_name>/client/<component_name>.js`).

*   The `mixin` method in the former `js_configure` block (now `client_class`) has been renamed to `include`.

*   Internal rework of component loading, which also changes some API and behavior.
    *   If the loaded component is a window, the show() method is called on it by Netzke. This can be prevented by the callback function returning `false` (which will also prevent other types of loaded components to be inserted in the container).
    *   On the client, the clientConfig config option renamed to serverConfig.
    *   To specify that a child component is eagerly loaded, the option is moved to the DSL `component` method itself:

          # BEFORE
          component :foo do |c|
            c.eager_loading = true
            ...
          end

          # NOW
          component :foo, eager_loading: true do |c|
            ...
          end

       Unless a component is declared as eagerly loaded, its config is no longer accessible on the client side (which means component is meant to be dynamically loadable).

*   Changes to how the endpoints API.
    *   Droped the `this` parameter from endpoint block on server side. It's still possible to call client-side methods as before, but `this` is declared in the class.

    *   Endpoint calls now accept any number of arguments (including 0), with client-side signature matching the server-side `endpoint` block, for example:

          # server side
          endpoint :assign_user do |user_id, table_id|
          end

          // client side
          this.assignUser(userId, tableId)

          ---

          # server side
          endpoint :clear_data do
          end

          // client side
          this.clearData()

    *   Whatever endpoint's server-side block returns will become the argument for the client-side callback function, for example:

          # server side
          endpoint :get_data do |params|
            [1, 2, 3]
          end

          // client side
          this.getData(params, function(result) {
            // result == [1, 2, 3]
          })

*   Drop listing header tools merely as symbols, as this was too limiting (e.g. Netzke was overriding the handler signature). As of now, use the Base#f method to specify the handler (will no longer be automatically set for you); see `spec/rails_app/app/components/tools.rb` for an example. Just reducing entropy, you know.

### Other changes

*   Introduce Base#f method that defines an inline wrapper for the client-side function that gets called in the scope of the component. This simplifies, for example, specifying handlers for buttons and tools, but also can be used in a few other occasions, where an Ext JS configuration option requires a function. See `spec/rails_app/app/components/actions.rb` for an example.

*   Calling `callParent` in JS functions from the "mixins" will now properly call the previous override if that was defined; see `spec/rails_app/app/components/js_mixins.rb` for an example.

Please check [0-12](https://github.com/netzke/netzke-core/blob/0-12/CHANGELOG.md) for previous changes.
