/*
This file gets loaded along with the rest of Ext library at the initial load
At this time the following constants have been set by Rails:

  Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
  Netzke.RelativeExtUrl - URL to ext files
*/

// Initial stuff
Ext.BLANK_IMAGE_URL = Netzke.RelativeExtUrl + "/resources/images/default/s.gif";
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext

Netzke.isLoading=function () {
  return Netzke.runningRequests != 0;
}
Netzke.runningRequests = 0;

Netzke.deprecationWarning = function(msg){
  if (typeof console == 'undefined') {
    // no console defined
  } else {
    console.info("Netzke: " + msg);
  }
};

Ext.ns('Netzke.page'); // namespace for all component instantces on the page
Ext.ns('Netzke.classes'); // namespace for all component classes
Ext.ns('Netzke.classes.Core'); // namespace for all component classes

Netzke.chainApply = function(){
  var res = {};
  Ext.each(arguments, function(o){
    Ext.apply(res, o);
  });
  return res;
};

// Some Ruby-ish String extensions
// from http://code.google.com/p/inflection-js/
String.prototype.camelize=function(lowFirstLetter)
{
  var str=this; //.toLowerCase();
  var str_path=str.split('/');
  for(var i=0;i<str_path.length;i++)
  {
    var str_arr=str_path[i].split('_');
    var initX=((lowFirstLetter&&i+1==str_path.length)?(1):(0));
    for(var x=initX;x<str_arr.length;x++)
      str_arr[x]=str_arr[x].charAt(0).toUpperCase()+str_arr[x].substring(1);
    str_path[i]=str_arr.join('');
  }
  str=str_path.join('::');
  return str;
};

String.prototype.capitalize=function()
{
  var str=this.toLowerCase();
  str=str.substring(0,1).toUpperCase()+str.substring(1);
  return str;
};

String.prototype.humanize=function(lowFirstLetter)
{
  var str=this.toLowerCase();
  str=str.replace(new RegExp('_id','g'),'');
  str=str.replace(new RegExp('_','g'),' ');
  if(!lowFirstLetter)str=str.capitalize();
  return str;
};

// This one is borrowed from prototype.js
String.prototype.underscore = function() {
  return this.replace(/::/g, '/')
             .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
             .replace(/([a-z\d])([A-Z])/g, '$1_$2')
             .replace(/-/g, '_')
             .toLowerCase();
};

// Usefull when using mixins
Netzke.aliasMethodChain = function(klass, method, feature) {
  klass[method + "Without" + feature.capitalize()] = klass[method];
  klass[method] = klass[method + "With" + feature.capitalize()];
};

Netzke.cache = [];

// Registering a Netzke component
Netzke.reg = function(xtype, klass) {
  if (!Ext.ComponentMgr.types[xtype]) {
    Ext.ComponentMgr.registerType(xtype, klass);
    Netzke.cache.push(xtype);
  }
};

Netzke.classes.Core.Mixin = {};

// Properties/methods common to all Netzke component classes
Netzke.componentMixin = Ext.applyIf(Netzke.classes.Core.Mixin, {
  isNetzke: true, // to distinguish Netzke components from regular Ext components
  latestResult: {}, // latest result returned from the server via an API call
  /*
  Overriding the constructor to only apply an "alias method chain" to initComponent
  */
  // constructor: function(config){
    // Netzke.aliasMethodChain(this, "initComponent", "netzke");
    // receiver.superclass.constructor.call(this, config);
  // },

  /*
  Dynamically creates methods for api points, so that we could later call them like: this.myEndpointMethod()
  */
  processEndpoints: function(){
    var endpoints = this.endpoints || [];
    endpoints.push('deliver_component'); // all Netzke components get this endpoint
    Ext.each(endpoints, function(intp){
      this[intp.camelize(true)] = function(args, callback, scope){ this.callServer(intp, args, callback, scope); }
    }, this);
  },

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
    Ext.DomHelper.append(head, {
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
  which *is* its widegt's real id. This methods, with the instance of "books" passed as parameter,
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
      },
      scope : this
    });
    Netzke.runningRequests--;
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
    var instance = Ext.create(config.alias, config);
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


// Feedback Ghost
Netzke.FeedbackGhost = function(){};
Ext.apply(Netzke.FeedbackGhost.prototype, {
  showFeedback: function(msg){
    var createBox = function(s, l){
        return ['<div class="msg">',
                '<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
                '<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc">', s, '</div></div></div>',
                '<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
                '</div>'].join('');
    }

    var showBox = function(msg, lvl){
      if (!lvl) {lvl = 'notice'};

      var msgCt = Ext.get('netzke-feedback') || Ext.DomHelper.insertFirst(document.body, {id: 'netzke-feedback', 'class':'netzke-feedback'}, true);

      var m = Ext.DomHelper.append(msgCt, {html:createBox(msg,lvl)}, true);
      m.slideIn('t').pause(2).ghost("b", {remove:true});
    }

    if (typeof msg != 'string') {
      var compoundMsg = "";
      Ext.each(msg, function(m){
        compoundMsg += m.msg + '<br>';
      });
      if (compoundMsg != "") showBox(compoundMsg, null); // the second parameter will be level
    } else {
      showBox(msg);
    }
  }
});
