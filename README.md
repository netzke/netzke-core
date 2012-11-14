# Netzke Core [![Build Status](https://secure.travis-ci.org/nomadcoder/netzke-core.png?branch=master)](http://travis-ci.org/nomadcoder/netzke-core) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/nomadcoder/netzke-core)

[RDocs](http://rdoc.info/projects/nomadcoder/netzke-core)

**WARNING 2012-10-20: This README is WIP, in the transition from v0.7 to v0.8. For v0.7 see the [0-7 branch](https://github.com/nomadcoder/netzke-core/tree/0-7).**

Netzke Core is the bare bones of the [Netzke framework](http://netzke.org). For pre-built full-featured components (like grids, forms, tab/accordion panels, etc), see [netzke-basepack](http://github.com/nomadcoder/netzke-basepack) and [netzke-communitypack](http://github.com/nomadcoder/netzke-communitypack).

Netzke Core takes the burden of implementing the following key aspects of the framework:

* Client-side (JavaScript) class generation
* Client-server communication
* Extendibility of components (class inheritance and mixins)
* Unlimited nesting (composition)
* Dynamic component loading
* JavaScript class caching
* Inclusion of “external” JavaScript and CSS files

All this extremely facilitates building fast, low-traffic, robust, and highly maintainable applications.

## Rationale

[Sencha Ext JS]("") is a powerful front-end framework, which is used for crafting web-apps that give the end user experience similar to that of a desktop application. It has an extensive set of widgets ('components'), and leverages a modular approach to its fullest: a developer can extend components (using Ext JS's own [class system]("")), nest components using many powerful layouts, dynamically create and destroy them. The architecture of Ext JS is well-thought and very complete.

However, with Ext JS being server-agnostic, it is not always a trivial task for a developer to bind Ext JS components to the server-side data *and* application business logic, especially in complex applications. Netzke as the solution that allows you to extend the modular approach to the server side.

## HelloWorld component

*This component is distributed as a part of the test application, see `test/core_test_app/components`.*

In `YOUR_APP/components/hello_world.rb`:

    class HelloWorld < Netzke::Base
      # Configure clint class
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
        c.bbar = [:ping_server] # embed the action into bottom toolbar
      end

      # Endpoint callable from client class
      endpoint :greet_the_world do |params,this|
        # call client class' method showGreeting
        this.show_greeting("Hello World!")
      end
    end

In `YOUR_APP/components/hello_world/javascripts/hello_world.js` put the client class (JavaScript) methods:

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

To embed the component in Rails view:

Add `netzke` routes:

    # in routes.rb
    RailsApp::Application.routes.draw do
      netzke
      ...
    end

Add `load_netzke` to the layout:

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

In the view:

    <%= netzke :hello_world %>

## What is a Netzke component

A Netzke component is a Ruby class, which is being represented by an Ext JS Component on the server-side. The responsibility of the Ruby class is to "assemble" that Ext JS class (further referred as "client class"), and provide the configuration for its instance (further referred as "client instance"). Even if it may sound a bit complicated, Netzke provides a simple API for defining the client class. See "Client class" for details.

With Netzke components being a Ruby class, and the client class being *incapsulated* in it, it is possible to use them by simply writing Ruby code. However, while creating a component, developers can fully use their Ext JS skills - Netzke puts no obstacles here.

A typical Netzke component's code is structured like this:

    your_web_app
      app
        components
          my_component.rb             <-- the Ruby class
          my_component
            some_module.rb            <-- optional extra Ruby modules
            javascripts
              some_dependency.js      <-- an external JS library
              init_component.js       <-- mixins to the client class
              extra_functionality.js  <-- more mixins (possibly optional, depending on the Ruby class configuration)
            stylesheets
              my_special_button.js    <-- custom CSS

## Client class

First of all it is necessary to understand that a client class is inherited (as defined by the Ext JS class system) from an Ext JS class, which by default is [Ext.panel.Panel](""). For example, a component defined like this:

    class HelloWorld < Netzke::Base
    end

will have the following client class (simplified):

    Ext.define('Netzke.classes.HelloWorld', Ext.apply(Netzke.componentMixin, {"extend":"Ext.panel.Panel"}));

`Netzke.componentMixin` contains a set of client-side methods common for all Netzke components.

The configuration of a client-class is done by using the `Netzke::Base.js_configure`. For example, in order to inherit from a different Ext JS component, and to mix in the methods defined in an external JavaScript class:

    class HelloWorld < Netzke::Base
      js_configure do |c|
        c.extend = "Ext.tab.Panel"
        c.mixin :extra_functionality
      end
    end

## Defining actions

## Client-server interaction within components

## Requirements

* Ruby ~> 1.9.2
* Rails ~> 3.2.0
* Ext JS ~> 4.1.0

## Getting started

* Follow the simple [installation](https://github.com/nomadcoder/netzke-core/wiki/Installation) steps.
* Learn how to build the [Hello World!](https://github.com/nomadcoder/netzke-core/wiki/Hello-world-extjs) component.
* Dive into the [documentation](https://github.com/nomadcoder/netzke/wiki).
* Get help on the [Google Groups](http://groups.google.com/group/netzke).

## Testing and playing with Netzke Core

Netzke Core is bundled with Cucumber and RSpec tests. If you would like to contribute to the project, you may want to learn how to [run the tests](https://github.com/nomadcoder/netzke-core/wiki/Automated-testing).

Besides, the bundled test application is a convenient [playground](https://github.com/nomadcoder/netzke-core/wiki/Playground) for those who search to experiment with the framework.

## Useful links
* [Project website](http://netzke.org)
* [Documentation](https://github.com/nomadcoder/netzke/wiki)
* [Live-demo](http://netzke-demo.herokuapp.com) (features [Netzke Basepack](https://github.com/nomadcoder/netzke-basepack), with sample code)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

## Ext JS 3 support
Versions 0.6.x are for you if you're using Ext 3 (*hardly maintained*)

---
Copyright (c) 2008-2012 nomadcoder, released under the MIT license

Note, that Ext JS itself is licensed [differently](http://www.sencha.com/products/extjs/license/)
