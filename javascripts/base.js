/**
This file gets loaded along with the rest of Ext library at the initial load. It is common for both Ext JS and Touch; Ext JS-specific stuff is in ext.js.

At this time the following constants have been set by Rails:

  Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
  Netzke.RelativeExtUrl - URL to ext files
*/

// Initial stuff
Netzke.classNamespace = 'Netzke.classes'; // TODO: pass from Ruby
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.ns('Netzke.page'); // namespace for all component instances on the page
Ext.ns(Netzke.classNamespace); // namespace for all component classes
Ext.ns('Netzke.classes.Core'); // namespace for Core mixins

Netzke.deprecationWarning = function(msg){
  if (typeof console == 'undefined') {
    // no console defined
  } else {
    console.info("Netzke: " + msg);
  }
};

Netzke.warning = Netzke.deprecationWarning;

Netzke.exception = function(msg) {
  throw("Netzke: " + msg);
};

// Used in testing
if( Netzke.nLoadingFixRequests == undefined ){
  Netzke.nLoadingFixRequests=0;
  Ext.Ajax.on('beforerequest',    function(conn,opt) { Netzke.nLoadingFixRequests+=1; });
  Ext.Ajax.on('requestcomplete',  function(conn,opt) { Netzke.nLoadingFixRequests-=1; });
  Ext.Ajax.on('requestexception', function(conn,opt) { Netzke.nLoadingFixRequests-=1; });
  Netzke.ajaxIsLoading = function() { return Netzke.nLoadingFixRequests > 0; };
}

// Used in testing, too
Netzke.runningRequests = 0;
Netzke.isLoading=function () {
  return Netzke.runningRequests != 0;
}

// Similar to Ext.apply, but can accept any number of parameters, e.g.
//
//     Netzke.chainApply(targetObject, {...}, {...}, {...});
Netzke.chainApply = function(){
  var res = {};
  Ext.each(arguments, function(o){
    Ext.apply(res, o);
  });
  return res;
};

// xtypes of cached Netzke classes
Netzke.cache = [];

Netzke.componentNotInSessionHandler = function() {
  throw "Netzke: component not in Rails session. Define Netzke.componentNotInSessionHandler to handle this.";
};

Netzke.classes.Core.Mixin = {};

// Properties/methods common to all Netzke component classes
Netzke.componentMixin = Ext.applyIf(Netzke.classes.Core.Mixin, {
  isNetzke: true, // to distinguish Netzke components from regular Ext components

  /*
  Evaluates CSS
  */
  evalCss : function(code){
    var head = Ext.fly(document.getElementsByTagName('head')[0]);
    Ext.core.DomHelper.append(head, {
      tag: 'style',
      type: 'text/css',
      html: code
    });
  },

  /*
  Evaluates JS
  */
  evalJs : function(code){
    eval(code);
  },

  /*
  Gets id in the context of provided parent.
  For example, the components "properties", being a child of "books" has global id "books__properties",
  which *is* its component's real id. This methods, with the instance of "books" passed as parameter,
  returns "properties".
  */
  localId : function(parent){
    return this.id.replace(parent.id + "__", "");
  },

  /*
  Executes a bunch of methods. This method is called almost every time a communication to the server takes place.
  Thus the server side of a component can provide any set of commands to its client side.
  Args:
    - instructions: can be
      1) a hash of instructions, where the key is the method name, and value - the argument that method will be called with (thus, these methods are expected to *only* receive 1 argument). In this case, the methods will be executed in no particular order.
      2) an array of hashes of instructions. They will be executed in order.
      Arrays and hashes may be nested at will.
      If the key in the instructions hash refers to a child Netzke component, bulkExecute will be called on that component with the value passed as the argument.

  Examples of the arguments:
      // same as this.feedback("Your order is accepted");
      {feedback: "You order is accepted"}

      // same as: this.setTitle('Suprise!'); this.setDisabled(true);
      [{setTitle:'Suprise!'}, {setDisabled:true}]

      // the same as this.getChildNetzkeComponent('users').bulkExecute([{setTitle:'Suprise!'}, {setDisabled:true}]);
      {users: [{setTitle:'Suprise!'}, {setDisabled:true}] }
  */
  bulkExecute : function(instructions){
    if (Ext.isArray(instructions)) {
      Ext.each(instructions, function(instruction){ this.bulkExecute(instruction)}, this);
    } else {
      for (var instr in instructions) {
        var args = instructions[instr];

        if (Ext.isFunction(this[instr])) {
          // Executing the method.
          this[instr].apply(this, args);
        } else {
          var childComponent = this.getChildNetzkeComponent(instr);
          if (childComponent) {
            childComponent.bulkExecute(args);
          } else if (Ext.isArray(args)) { // only consider those calls that have arguments wrapped in an array; the only (probably) case when they are not, is with 'success' property set to true in a non-ajax form submit - silently ignore that
            throw "Netzke: Unknown method or child component '" + instr +"' in component '" + this.id + "'"
          }
        }
      }
    }
  },

  // Does the call to the server and processes the response
  callServer : function(intp, params, callback, scope){
    Netzke.runningRequests++;
    if (!params) params = {};
      Ext.Ajax.request({
      params: params,
      url: this.endpointUrl(intp),
      callback: function(options, success, response){
        if (success && response.responseText) {
          // execute commands from server
          this.bulkExecute(Ext.decode(response.responseText));

          // provide callback if needed
          if (typeof callback == 'function') {
            if (!scope) scope = this;
            callback.apply(scope, [this.latestResult]);
          }
        }
        Netzke.runningRequests--;
      },
      scope : this
    });
  },

  setResult: function(result) {
    this.latestResult = result;
  },

  // When an endpoint call is issued while the session has expired, this method is called. Override it to do whatever is appropriate.
  componentNotInSession: function() {
    Netzke.componentNotInSessionHandler();
  },

  // Returns a URL for old-fashion requests (used at multi-part form non-AJAX submissions)
  endpointUrl: function(endpoint){
    return Netzke.RelativeUrlRoot + "/netzke/dispatcher?address=" + this.id + "__" + endpoint;
  },

  // private
  normalizeConfigArray: function(items){
    var cfg, ref, cmpName, cmpCfg, actName, actCfg;

    Ext.each(items, function(item, i){
      cfg = item;

      // potentially, referencing a component or action with a string
      if (Ext.isString(item)) {
        ref = item.camelize(true);
        if ((this.netzkeComponents || {})[ref]) cfg = {netzkeComponent: ref};
        else if ((this.actions || {})[ref]) cfg = {netzkeAction: ref};
      }

      if (cfg.netzkeAction) {
        actName = cfg.netzkeAction.camelize(true);
        if (!this.actions[actName]) throw "Netzke: unknown action " + cfg.netzkeAction;

        items[i] = this.actions[actName];
        delete(item);
      } else if (cfg.netzkeComponent) {
        cmpName = cfg.netzkeComponent;
        cmpCfg = this.netzkeComponents[cmpName.camelize(true)];
        if (!cmpCfg) throw "Netzke: unknown component " + cmpName;
        items[i] = Ext.apply(cmpCfg, cfg);
        delete(item);
      } else {
        for (key in cfg) {
          if (Ext.isArray(cfg[key])) {
            this.normalizeConfigArray(cfg[key]);
          }
        }
      }
    }, this);
  },
});
