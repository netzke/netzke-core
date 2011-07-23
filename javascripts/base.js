/*
This file gets loaded along with the rest of Ext library at the initial load
At this time the following constants have been set by Rails:

  Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
  Netzke.RelativeExtUrl - URL to ext files
*/

// Initial stuff
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.ns('Netzke.page'); // namespace for all component instances on the page
Ext.ns('Netzke.classes'); // namespace for all component classes
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

/* Similar to Rails' alias_method_chain. Usefull when using mixins. E.g.:

    Netzke.aliasMethodChain(this, "initComponent", "netzke")

    will result in 2 new methods on this.initComponentWithNetzke and this.initComponentWithoutNetzke
*/
Netzke.aliasMethodChain = function(klass, method, feature) {
  klass[method + "Without" + feature.capitalize()] = klass[method];
  klass[method] = klass[method + "With" + feature.capitalize()];
};

// xtypes of cached Netzke classes
Netzke.cache = [];

// Registering a Netzke component
// TODO: MAV I think we should get rid of this piece of code someday
// and use Ext4's ClassManager functions instead
Netzke.reg = function(xtype, klass) {
  if (!Ext.ComponentManager.types[xtype]) {
    // MAV not needed in v4, I guess
    // Ext.ComponentManager.registerType(xtype, klass);
    Netzke.cache.push(xtype);
  }
};

Netzke.componentNotInSessionHandler = function() {
  throw "Netzke: component not in Rails session. Define Netzke.componentNotInSessionHandler to handle this.";
};

Netzke.classes.Core.Mixin = {};

// Properties/methods common to all Netzke component classes
Netzke.componentMixin = Ext.applyIf(Netzke.classes.Core.Mixin, {
  isNetzke: true, // to distinguish Netzke components from regular Ext components

  /*
  Detects component placeholders in the passed object (typically, "items"),
  and merges them with the corresponding config from this.components.
  This way it becomes ready to be instantiated properly by Ext.
  */
  detectComponents: function(o){
    if (Ext.isObject(o)) {
      if (o.items) this.detectComponents(o.items);
    } else if (Ext.isArray(o)) {
      var a = o;
      Ext.each(a, function(el, i){
        if (el.component) {
          a[i] = Ext.apply(this.components[el.component.camelize(true)], el);
          delete a[i].component;
        } else if (el.items) this.detectComponents(el.items);
      }, this);
    }
  },

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
        if (Ext.isFunction(this[instr])) {
          // Executing the method.
          this[instr].apply(this, [instructions[instr]]);
        } else {
          var childComponent = this.getChildNetzkeComponent(instr);
          if (childComponent) {
            childComponent.bulkExecute(instructions[instr]);
          } else {
            throw "Netzke: Unknown method or child component '" + instr +"' in component '" + this.id + "'"
          }
        }
      }
    }
  },

  // Used by Touch components
  endpointUrl: function(endpoint){
    return Netzke.RelativeUrlRoot + "/netzke/dispatcher?address=" + this.id + "__" + endpoint;
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
  }
});


// DEPRECATED: Netzke extensions for Ext.Container
Ext.override(Ext.Container, {
  // Instantiates an component by its config. If it appears to be a window, shows it instead of adding as item.
  instantiateChild: function(config){
    Netzke.deprecationWarning("instantiateChild is deprecated");
    var instance = Ext.createByAlias( config.alias, config );
    this.insertNetzkeComponent(instance);
    return instance;
  },

  insertNetzkeComponent: function(cmp) {
    this.removeChild(); // first delete previous component
    this.add(cmp);

    // Sometimes a child is getting loaded into a hidden container...
    if (this.isVisible()) {
      this.doLayout();
    } else {
      this.on('show', function(cmp){cmp.doLayout();}, {single: true});
    }
  },

  /**
    Get Netzke component that this Ext.Container is part of (*not* the parent component, for which call getParent)
    It searches up the Ext.Container hierarchy until it finds a Container that has isNetzke property set to true
    (or until it reaches the top).
  */
  getOwnerComponent: function(){
    Netzke.deprecationWarning("getOwnerComponent is deprecated");
    if (this.initialConfig.isNetzke) {
      return this;
    } else {
      if (this.ownerCt){
        return this.ownerCt.getOwnerComponent();
      } else {
        return null;
      }
    }
  },

  // Get the component that we are hosting
  getNetzkeComponent: function(){
    Netzke.deprecationWarning("getNetzkeComponent is deprecated");
    return this.items ? this.items.first() : null; // need this check in case when the container is not yet rendered, like an inactive tab in the TabPanel
  },

  // Remove the child
  removeChild: function(){
    Netzke.deprecationWarning("removeChild is deprecated");
    var currentChild = this.getNetzkeComponent();
    if (currentChild) {this.remove(currentChild);}
  }
});
