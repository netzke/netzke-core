# Netzke Core [![Build Status](https://secure.travis-ci.org/nomadcoder/netzke-core.png?branch=master)](http://travis-ci.org/nomadcoder/netzke-core) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/netzke/netzke-core) [![Gem Version](https://fury-badge.herokuapp.com/rb/netzke-core.png)](http://badge.fury.io/rb/netzke-core)

[RDocs](http://rdoc.info/projects/netzke/netzke-core)

Netzke Core is the bare bones of the [Netzke framework](http://netzke.org). For pre-built full-featured components (like grids, forms, tab/accordion panels, etc), see [netzke-basepack](http://github.com/netzke/netzke-basepack) and [netzke-communitypack](http://github.com/netzke/netzke-communitypack).

Some knowledge of Sencha Ext JS will be needed in order to fully understand this overview.

## Rationale

[Sencha Ext JS]("http://www.sencha.com/products/extjs") is a powerful front-end framework, which is used for crafting web-apps that give the end user experience similar to that of a desktop application. It has an extensive set of widgets ('components'), and leverages a modular approach to its fullest: a developer can extend components (using Ext JS's own [class system]("http://docs.sencha.com/ext-js/4-1/#!/guide/class_system")), nest components using many powerful layouts, dynamically create and destroy them. The architecture of Ext JS is well-thought and very complete.

However, with Ext JS being server-agnostic, it is not always a trivial task for a developer to bind Ext JS components to the server-side data *and* application business logic, especially in complex applications. Netzke as the solution that allows you to extend the modular approach to the server side.

Netzke Core takes the burden of implementing the following key aspects of the framework:

* Client-side (JavaScript) class generation
* Client-server communication
* Convenient declaration of Ext actions
* Extendibility of components (class inheritance and mixins)
* Unlimited nesting (composition)
* Dynamic component loading
* Client-side class caching
* Inclusion of extra JavaScript and CSS files

...and more.

All this extremely facilitates building fast, low-traffic, robust, and highly maintainable applications. As a result, your code scales much better in the sense of complexity, compared to using conventional MVC, where developers are pretty much limited with programming techniques they can apply.

## HelloWorld component

*This component is distributed as a part of the test application, see `test/core_test_app/components`.*

Ext JS files are not distributed with Netzke, so, make sure that they are located in (or sym-linked as) `YOUR_APP/public/extjs`.

In `YOUR_APP/components/hello_world.rb`:

```ruby
class HelloWorld < Netzke::Base
  # Configure client class
  js_configure do |c|
    c.title = "Hello World component"
    c.mixin # mix in methods from hello_world/javascripts/hello_world.js
  end

  # Actions are used by Ext JS to share functionality and state b/w buttons and menu items
  # The handler for this action should be called onPingServer by default
  action :ping_server

  # Self-configure with a bottom toolbar
  def configure(c)
    super
    c.bbar = [:ping_server] # embed the action into bottom toolbar as a button
  end

  # Endpoint callable from client class
  endpoint :greet_the_world do |params,this|
    # call client class' method showGreeting
    this.show_greeting("Hello World!")
  end
end
```

In `YOUR_APP/components/hello_world/javascripts/hello_world.js` put the client class (JavaScript) methods:

```javascript
{
  // handler for the ping_server action
  onPingServer: function(){
    // calling greet_the_world endpoint
    this.greetTheWorld();
  },

  // called by the server as the result of executing the endpoint
  showGreeting: function(greeting){
    this.update("Server says: " + greeting);
  }
}
```

To embed the component in Rails view:

Add `netzke` routes:

```ruby
# in routes.rb
RailsApp::Application.routes.draw do
  netzke
  ...
end
```

Use `load_netzke` in the layout to include Ext JS and Netzke scripts and stylesheets:

```erb
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-type" content="text/html; charset=utf-8">
  <%= csrf_meta_tag %>
  <%= load_netzke %>
</head>
<body>
  <%= yield %>
</body>
</html>
```

Embed the component in the Rails view:

```erb
<%= netzke :hello_world %>
```

## What is a Netzke component

A Netzke component is a Ruby class (further referred to as "server class"), which is being represented by an Ext JS Component on the server-side (further referred to as "client class"). The responsibility of the server class is to "assemble" the client class and provide the configuration for its instance (further referred as "client class instance"). Even if it may sound a bit complicated, Netzke provides a simple API for defining and configuring the client class. See [Client class](#client-class) for details.

Further, each Netzke component inherits convenient API for enabling the communication between the client and server class. See [Client-server interaction](#client-server-interaction) for details.

With Netzke components being a Ruby class, and the client class being *incapsulated* in it, it is possible to use a Netzke component in your application by simply writing Ruby code. However, while creating a component, developers can fully use their Ext JS skills - Netzke puts no obstacles here.

A typical Netzke component's code is structured like this (on example of MyComponent):

```
your_web_app
  app
    components
      my_component.rb             <-- the Ruby class
      my_component
        some_module.rb            <-- optional extra Ruby code
        javascripts
          some_dependency.js      <-- optional external JS library
          init_component.js       <-- optional mixins to the client class
          extra_functionality.js  <-- more mixins (mixin-in may depend on component class configuration)
        stylesheets
          my_special_button.css    <-- optional custom CSS
```

## Client class

The generated client class is *inherited* (as defined by the Ext JS [class system]("http://docs.sencha.com/ext-js/4-1/#!/guide/class_system")) from an Ext JS class, which by default is [Ext.panel.Panel]("http://docs.sencha.com/ext-js/4-1/#!/api/Ext.panel.Panel"). For example, a component defined like this:

```ruby
class HelloWorld < Netzke::Base
end
```

will have the following client class generated by Netzke (simplified):

```javascript
Ext.define('Netzke.classes.HelloWorld', {"extend":"Ext.panel.Panel", "mixins":["Netzke.classes.Core.Mixin"]});
```

`Netzke.classes.Core.Mixin` contains a set of client class methods and properties common to every Netzke component.

Extending `HelloWorld` will be automatically reflected on the client-class level:

```ruby
class HelloNewWorld < HelloWorld
end
```

will have the following client class generated (simplified):

```javascript
Ext.define('Netzke.classes.HelloNewWorld', {"extend":"Netzke.classes.HelloWorld"});
```

The configuration of a client-class is done by using the `Netzke::Base.js_configure`. For example, in order to inherit from a different Ext JS component, and to mix in the methods defined in an external JavaScript class:

```ruby
class MyTabPanel < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.tab.Panel"
    c.mixin :extra_functionality
  end
end
```

For more details on defining the client class, refer to [Netzke::Core::ClientClass](http://rdoc.info/github/netzke/netzke-core/Netzke/Core/ClientClass).

## Composition

Any Netzke component can define child components, which can either be statically nested in the compound layout (e.g. as different regions of the ['border' layout]("http://docs.sencha.com/ext-js/4-1/#!/api/Ext.layout.container.Border")), or dynamically loaded at a request (as in the case of the edit form window in `Netzke::Basepack::GridPanel`, for example).

### Defining child components
 
You can define a child component by calling the `component` class method which normally requires a block:
 
```ruby
component :users do |c|
  c.klass = GridPanel
  c.model = "User"
  c.title = "Users"
end
```

### Nesting components

Declared components can be referred to in the component layout:

```ruby
def configure(c)
  super
  c.items = [
    { xtype: :panel, title: "Simple Ext panel" },
    :users
  ]
end
```

### Dynamic loading of components

Next to being statically nested in the layout, a child component can also be dynamically loaded by using client class' `netzkeLoadComponent` method:

    this.netzkeLoadComponent('users');

this will load the "users" component and [add](http://docs.sencha.com/ext-js/4-1/#!/api/Ext.container.Container-method-add) it to the current container.

For more details on dynamic component loading refer to inline docs of [javascript/ext.js](https://github.com/netzke/netzke-core/blob/master/javascripts/ext.js).

For more details on composition refer to [Netzke::Core::Composition](http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Composition).

## Actions, toolbars, and menus

Actions are [used by Ext JS]("http://docs.sencha.com/ext-js/4-1/#!/api/Ext.Action") to share functionality and state among multiple buttons and menu items. Define actions with the `action` class method:

```ruby
action :show_report do |c|
  c.text = "Show report"
  c.icon = :report
end
```

The icon for this button will be `images/icons/report.png` (see [Icons support](#icons-support)).

Refer to actions in toolbars:

```ruby
def configure(c)
  super
  c.bbar = [:show_report]
end
```

Actions can also be referred to is submenus:

```ruby
  c.tbar = [{text: 'Menu', menu: {items: [:show_report]}}]
```

For more details on composition refer to [Netzke::Core::Action](http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Action).

## Client-server interaction

Communication between the client class and the corresponding server class is done by means of defining *endpoints*. By defining an endpoint on the server, the client class automatically gets a method that is used to call the server.

### Calling an endpoint from client class

By defining an endpoint like this:

```ruby
class SimpleComponent < Netzke::Base
  endpoint :whats_up_server do |params, this|
  # ...
  end
end
```

...the client class will obtain a method called `whatsUpServer`:

```javascript
this.whatsUpServer(params, callback, scope);
```

Parameters:

* `params` will be passed to the endpoint block as the first parameter
* `callback` (optional) receives a function to be called after the server successfully processes the endpoint call
* `scope` (optional) is the scope in which the callback function will be called

### Calling client class methods from endpoint

An endpoint can instruct the client class to execute a set of methods after its execution, passing those methods arbitrary parameters. For example:

```ruby
class SimpleComponent < Netzke::Base
  endpoint :whats_up_server do |params, this|
    this.set_title("All quiet here on the server")
    this.my_method
  end
end
```

Here the client class will call its `setTitle` method (defined in `Ext.panel.Panel`) with parameter passed from the endpoint. Then a custom method `myMethod` will be called with no parameters.

For more details on client-server communication see [Netzke::Core::Services]("http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Services").

## Icons support

Netzke can optionally make use of icons for making clickable elements like buttons and menu items more visual. The icons should be (by default) located in `public/images/icons`.

An example of specifying an icon for an action:

```ruby
action :logout do |c|
  c.icon = :door
end
```

The logout action will be configured with `public/images/icons/door.png` as icon.

For more details on using icons refer to [Netzke::Core::Actions]("http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Actions").

## I18n

Netzke Core will automatically include Ext JS localization files based on current `I18n.locale`.

Also, Netzke Core uses some conventions for localizing actions. Refer to [Netzke::Core::Actions](http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Actions).

## Requirements

* Ruby ~> 1.9.2
* Rails ~> 3.2.0
* Ext JS ~> 4.1.0

## Installation

  $ gem install netzke-core

For the latest ("edge") stuff, instruct the bundler to get the gem straight from github:

```ruby
gem 'netzke-core', git: "git://github.com/netzke/netzke-core.git"
```

By default, Netzke assumes that your Ext JS library is located in public/extjs. It can be a symbolic link, e.g.:

    $ ln -s ~/code/sencha/ext-4.1.1 public/extjs

*(Make sure that the location of the license.txt distributed with Ext JS is exactly `public/extjs/license.txt`)*

## Running tests

The bundled `test/core_test_app` application used for automated testing can be easily run as a stand-alone Rails app. It's a good source of concise, focused examples. After starting the application, access any of the test components (located in `app/components`) by using the following url:

    http://localhost:3000/components/{name of the component's class}

For example [http://localhost:3000/components/ServerCaller](http://localhost:3000/components/ServerCaller)

To run all the tests (from the gem's root):

    $ rake

This assumes that the Ext JS library is located/symlinked in `test/core_test_app/public/extjs`. If you want to use Sencha CDN instead, run:

    $ EXTJS_SRC=cdn rake

## Useful links
* [Project website](http://netzke.org)
* [Live demo](http://netzke-demo.herokuapp.com) (features [Netzke Basepack](https://github.com/netzke/netzke-basepack), with sample code)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

---
Copyright (c) 2008-2012 [nomadcoder](https://twitter.com/nomadcoder), released under the MIT license (see LICENSE).

**Note** that Ext JS is licensed [differently](http://www.sencha.com/products/extjs/license/), and you may need to purchase a commercial license in order to use it in your projects!
