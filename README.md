# Netzke Core

[![Build Status](https://secure.travis-ci.org/skozlov/netzke-core.png?branch=master)](http://travis-ci.org/skozlov/netzke-core)

Netzke Core is the bare bones of the [Netzke framework](https://github.com/nomadcoder/netzke). For pre-built full-featured components (like grids, forms, tab/accordion panels, applications, etc), see [netzke-basepack](http://github.com/nomadcoder/netzke-basepack) (Ext JS).

Netzke Core takes the burden of implementing the following key aspects of the framework:

* JavaScript class generation
* Client-server communication
* Extendibility of components (with OOP, in both Ruby and JavaScript)
* Unlimited nesting (composition)
* Dynamic component loading
* JavaScript class caching
* Inclusion of “external” JavaScript CSS files
* ... and more

All this provides for fast, low-traffic, robust, highly maintainable applications.

## Requirements

* Ruby >= 1.9.2 (1.8.7 may work, too)
* Rails ~> 3.1.0
* Ext JS = 4.0.2a

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
* [Live-demo](http://demo.netzke.org) (features [Netzke Basepack](https://github.com/nomadcoder/netzke-basepack), with sample code)
* [Twitter](http://twitter.com/netzke) - latest news about the framework
* [Author's twitter](http://twitter.com/nomadcoder) - author's rambling about OS X, productivity, lifestyle, and what not

## Ext 3 support
Versions 0.6.x are for you if you're using Ext 3 (*hardly maintained*)

## Rails 2 support
With Rails 2 (and Ext 3 only), use versions 0.5.x (*not maintained*)

---
Copyright (c) 2008-2011 NomadCoder, released under the MIT license
Note, that Ext JS itself is licensed [differently](http://www.sencha.com/products/extjs/license/)
