/*
This file gets loaded along with the rest of Ext library at the initial load
At this time the following constants have been set by Rails:

  Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
  Netzke.RelativeExtUrl - URL to ext files
*/

// Initial stuff
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.ns('Netzke.page'); // namespace for all component instantces on the page
Ext.ns('Netzke.classes'); // namespace for all component classes
Ext.ns('Netzke.classes.Core'); // namespace for Core mixins

Netzke.deprecationWarning = function(msg){
  if (typeof console == 'undefined') {
    // no console defined
  } else {
    console.info("Netzke: " + msg);
  }
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
    - instructions: array of methods, in the order of execution.
      Each item is an object in one of the following 2 formats:
        1) {method1:args1, method2:args2}, where methodN is a name of a public method of this component; these methods are called in no particular order
        2) {component:component_id, methods:arrayOfMethods}, used for recursive call to bulkExecute on some child component

  Example:
    - [
        // the same as this.feedback("Your order is accepted")
        {feedback: "You order is accepted"},

        // the same as this.getChildComponent('users').bulkExecute([{setTitle:'Suprise!'}, {setDisabled:true}])
        {component:'users', methods:[{setTitle:'Suprise!'}, {setDisabled:true}] },

        // ... etc:
        {updateStore:{records:[[1, 'Name1'],[2, 'Name2']], total:10}},
        {setColums:[{},{}]},
        {setMenus:[{},{}]},
        ...
      ]
  */
  bulkExecute : function(instructions){
    if (Ext.isArray(instructions)) {
      Ext.each(instructions, function(instruction){ this.bulkExecute(instruction)}, this);
    } else {
      for (var instr in instructions) {
        if (Ext.isFunction(this[instr])) {
          // Executing the method. If arguments are an array, expand that into arguments.
          this[instr].apply(this, Ext.isArray(instructions[instr]) ? instructions[instr] : [instructions[instr]]);
        } else {
          var childComponent = this.getChildComponent(instr);
          if (childComponent) {
            childComponent.bulkExecute(instructions[instr]);
          } else {
            throw "Netzke: Unknown method or child component '" + instr +"' in component '" + this.id + "'"
          }
        }
      }
    }
  },

  // Returns API url based on provided API point
  buildApiUrl: function(endpoint){
    Netzke.deprecationWarning("buildApiUrl() is deprecated. Use endpointUrl() instead.");
    return this.endpointUrl(endpoint);
  },

  // endpointUrl: function(endpoint){
  //   Netzke.deprecationWarning("endpointUrl() is deprecated. Use Ext.direct counterparts instead.\nFor example, specify a DirectProxy instead of HttpProxy ( proxy: new Ext.data.DirectProxy({directFn: Netzke.providers[this.id].endPoint}) ),\nor specify api instead of url config option for BasicForm ( api: { load: Netzke.providers[this.id].loadEndPoint, submit: Netzke.providers[this.id].submitEndPoint} )");
  //   return Netzke.RelativeUrlRoot + "/netzke/" + this.id + "__" + endpoint;
  // },

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
  }
});


// Netzke extensions for Ext.Container
Ext.override(Ext.Container, {
  // Instantiates an component by its config. If it appears to be a window, shows it instead of adding as item.
  // TODO: there must be a method to just instantiate a component, but not to add/show it instantly.
  instantiateChild : function(config){
    var instance = Ext.createByAlias( config.alias, config );
    if (instance.isXType("window")) {
      instance.show();
    } else {
      this.removeChild(); // first delete previous component
      this.add(instance);

      // Sometimes a child is getting loaded into a hidden container...
      if (this.isVisible()) {
        this.doLayout();
      } else {
        this.on('show', function(cmp){cmp.doLayout();}, {single: true});
      }

    }
    return instance;
  },

  /**
    Get Netzke component that this Ext.Container is part of (*not* the parent component, for which call getParent)
    It searches up the Ext.Container hierarchy until it finds a Container that has isNetzke property set to true
    (or until it reaches the top).
  */
  getOwnerComponent : function(){
    if (this.initialConfig.isNetzke) {
      return this;
    } else {
      if (this.ownerCt){
        return this.ownerCt.getOwnerComponent()
      } else {
        return null
      }
    }
  },

  // Get the component that we are hosting
  getNetzkeComponent: function(){
    return this.items ? this.items.first() : null; // need this check in case when the container is not yet rendered, like an inactive tab in the TabPanel
  },

  // Remove the child
  removeChild : function(){
    var currentChild = this.getNetzkeComponent();
    if (currentChild) {this.remove(currentChild);}
  }
});
