# ToDo
Make it possible to pass a constant (not a string) to the `class_name` option

Make :lazy_loading "true" by default when defining a child component

Make :items option also accept a hash.

Caching for netzke_controller-provided JS and CSS.

Caching - investigate reusing (fragment?) caching of Rails.

Move JS classes out of the main page to a cachable includes (moffff)


## Roadmap

### 0.8

Get rid of Symbol#action and Symbol#component

Get rid of String#l


## Ideas that didn't work out

### Making value from super-class accessible in the block parameters in endpoints

    endpoint :call_server do |params, orig|
      orig.merge(:set_title => orig[:set_title] + " extended")
    end

Bad idea because calling the super method is often required AFTER doing something in the override, not BEFORE. For example, deliver_component in GridPanel in Basepack is overridden to reconfigure the components on the fly before actually delivering the component (i.e. calling super).
So, to override an endpoint, simply define a method with endpoint's name, e.g.:

    def call_server(params)
      super.merge(...)
    end
