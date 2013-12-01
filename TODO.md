## Roadmap

### v1.0

  * `js_configure`: c.mixin and c.include without params pickup "mixins/*.js" and "includes/*.js" respectively
  * new convention for endpoint naming: an endpoint declared with `endpoint :do_something` will be callable from
  the client as `this.serverDoSomething`
  * netzkeFeedback removed in favor of netzkeInfo and netzkeError
  * Grid config options like `enable_advanced_search` loose their `enable_` prefix
