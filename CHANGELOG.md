*   Introduce Base#f method that defines an inline wrapper for the client-side function that gets called in the scope of the component. This simplifies, for example, specifying handlers for buttons and tools, but also can be used in a few other occasions, where an Ext JS configuration option requires a function. See `spec/rails_app/app/components/actions.rb` for an example.
*   Calling `callParent` in JS functions from the "mixins" will now properly call the previous override if that was defined; see `spec/rails_app/app/components/js_mixins.rb` for an example.

Please check [0-12](https://github.com/netzke/netzke-core/blob/0-12/CHANGELOG.md) for previous changes.
