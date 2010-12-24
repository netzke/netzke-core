## Netzke Core

Netzke is a framework that greatly facilitates creation of Sencha [Ext JS](http://www.sencha.com/products/extjs/) / [Touch](http://www.sencha.com/products/touch/) + [Ruby-on-Rails](http://rubyonrails.org/) applications by offering you a true component-oriented approach. Using components gives you the following advantages:

* __Reusability__. Write a component once, and use it throughout your application easily, or share it between applications.
* __Composability__. Build new components by combining existing components.
* __Extensibility__. Components are Ruby classes, and can be easily extended using the object-oriented approach.
* __Encapsulation__. You don't need to know JavaScript or Sencha libraries in order to be able to use existing components.

Having these at your disposal, you can quickly build _amazingly_ complex RIA ("Rich Internet Applications") without turning your code into a mess.

Netzke Core is the bare bones of the Netzke framework. For **pre-built full-featured components** (like grids, forms, tab/accordion panels, applications, etc), see [netzke-basepack](http://github.com/skozlov/netzke-basepack) (Ext JS).

### Getting started

* Follow the simple [installation](https://github.com/skozlov/netzke-core/wiki/Installation) steps.
* Learn how to build the [Hello World!](https://github.com/skozlov/netzke-core/wiki/Hello-world-extjs) component.
* Dive into the [documentation](https://github.com/skozlov/netzke/wiki).
* Get help on the [Google Groups](http://groups.google.com/group/netzke).

### Sencha Touch support

Netzke Core has support for Sencha Touch, so you can create components for mobile web apps as easily.

* Learn how to build the [Hello World!](https://github.com/skozlov/netzke-core/wiki/Hello-world-touch) Sencha Touch component.

### Automated tests

* Learn how to run Cucumber and RSpec [tests](https://github.com/skozlov/netzke-core/wiki/Automated-testing).

### Playground

The `test/rails_app` application used for automated testing is also a convenient playground to learn more about the framework, as it may be run as a stand-alone Rails app. Besides, it's a pretty good source of concise, focused examples. After starting the application, access any of the `app/components` test components by using the following url:

    http://localhost:3000/components/{name of the component's class}

e.g.:

    http://localhost:3000/components/ServerCaller

or, for scoped components:

    http://localhost:3000/components/ScopedComponents::SomeScopedComponent

### More info
* [Project website](http://netzke.org)
* [Live-demo](http://demo.netzke.org) (with sample code)
* I'm [twitting](http://twitter.com/skozlov) about Netzke development
* The [netzke-basepack](https://github.com/skozlov/netzke-basepack) project (pre-built full-featured components)


*Copyright (c) 2008-2010 Sergei Kozlov, released under the MIT license*
