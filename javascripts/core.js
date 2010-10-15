/*
This file gets loaded along with the rest of Ext library at the initial load
At this time the following constants have been set by Rails:

  Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
  Netzke.RelativeExtUrl - URL to ext files
*/

// Initial stuff
Ext.BLANK_IMAGE_URL = Netzke.RelativeExtUrl + "/resources/images/default/s.gif";
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext

Netzke.deprecationWarning = function(msg){
  if (typeof console == 'undefined') {
    // no console defined
  } else {
    console.info("Netzke: " + msg);
  }
};

// Check Ext JS version
(function(){
  var requiredExtVersion = "3.3.0";
  var currentExtVersion = Ext.version;
  if (requiredExtVersion !== currentExtVersion) {
    Netzke.deprecationWarning("Netzke needs Ext " + requiredExtVersion + ". You have " + currentExtVersion + ".");
  }
})();

Ext.ns('Netzke.page'); // namespace for all component instantces on the page
Ext.ns('Netzke.classes'); // namespace for all component classes

// Because of Netzke's double-underscore notation, Ext.TabPanel should have a different id-delimiter (yes, this should be in netzke-core)
Ext.TabPanel.prototype.idDelimiter = "___";

Ext.QuickTips.init();

// We don't want no state managment by default, thank you!
Ext.state.Provider.prototype.set = function(){};

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
}

// Usefull when using mixins
Netzke.aliasMethodChain = function(klass, method, feature) {
  klass[method + "Without" + feature.capitalize()] = klass[method];
  klass[method] = klass[method + "With" + feature.capitalize()];
}

// Properties/methods common to all component classes
Netzke.componentMixin = function(receiver){
  return {
    height: 400,
    border: false,
    isNetzke: true, // to distinguish Netzke components from regular Ext components
    latestResult: {}, // latest result returned from the server via an API call
    
    /*
    Overriding the constructor to only apply an "alias method chain" to initComponent
    */
    constructor : function(config){
      Netzke.aliasMethodChain(this, "initComponent", "netzke");
      receiver.superclass.constructor.call(this, config);
    },
    
    /* initComponent common for all Netzke components */
    initComponentWithNetzke : function(){
      this.normalizeActions();
      
      this.detectActions(this);
      
      this.detectComponents(this.items);
      
      this.normalizeTools();
      
      this.processEndpoints();
      
      // This is where the references to different callback functions will be stored
      this.callbackHash = {};
      
      // This is where we store the information about components that are currently being loaded with this.loadComponent()
      this.componentsBeingLoaded = {};

      // Set title
      if (this.mode === "config"){
        if (!this.title) {
          this.title = '[' + this.id + ']';
        } else {
          this.title = this.title + ' [' + this.id + ']';
        }
      } else {
        if (!this.title) {
          this.title = this.id.humanize();
        }
      }

      // From everywhere accessible FeedbackGhost
      this.feedbackGhost = new Netzke.FeedbackGhost();

      // Call the original initComponent
      this.initComponentWithoutNetzke();
    },

    /* 
    Dynamically creates methods for api points, so that we could later call them like: this.myEndpointMethod() 
    */
    processEndpoints : function(){
      var endpoints = this.endpoints || [];
      endpoints.push('deliver_component'); // all Netzke components get this endpoint
      Ext.each(endpoints, function(intp){
        this[intp.camelize(true)] = function(args, callback, scope){ this.callServer(intp, args, callback, scope); }
      }, this);
    },

    normalizeTools: function() {
      if (this.tools) {
        var normTools = [];
        Ext.each(this.tools, function(tool){
          // Create an event for each action (so that higher-level components could interfere)
          this.addEvents(tool.id+'click');
      
          var handler = this.toolActionHandler.createDelegate(this, [tool]);
          normTools.push({id : tool, handler : handler, scope : this});
        }, this);
        this.tools = normTools;
      }
    },

    /* 
    Replaces actions configs with Ext.Action instances, assigning default handler to them 
    */
    normalizeActions : function(){
      var normActions = {};
      for (var name in this.actions) {
        // Create an event for each action (so that higher-level components could interfere)
        this.addEvents(name+'click');

        // Configure the action
        var actionConfig = this.actions[name];
        actionConfig.customHandler = actionConfig.handler;
        actionConfig.handler = this.actionHandler.createDelegate(this); // handler common for all actions
        actionConfig.name = name;
        normActions[name] = new Ext.Action(actionConfig);
      }
      delete(this.actions);
      this.actions = normActions;
    },

    /*
    Detects action configs in the passed object, and replaces them with instances of Ext.Action created by normalizeActions().
    This detects action in arbitrary level of nesting, which means you can put any other components in your toolbar, and inside of them specify menus/items or even toolbars.
    */
    detectActions: function(o){
      if (Ext.isObject(o)) {
        if ((typeof o.handler === 'string') && Ext.isFunction(this[o.handler.camelize(true)])) {
           // This button config has a handler specified as string - replace it with reference to a real function if it exists
          o.handler = this[o.handler.camelize(true)].createDelegate(this);
        }
        // TODO: this should be configurable!
        Ext.each(["bbar", "tbar", "fbar", "menu", "items", "contextMenu", "buttons"], function(key){
          if (o[key]) {
            this.detectActions(o[key]);
          }
        }, this);
      } else if (Ext.isArray(o)) {
        var a = o;
        Ext.each(a, function(el, i){
          if (Ext.isObject(el)) {
            if (el.action) {
              a[i] = this.actions[el.action.camelize(true)];
            } else {
              this.detectActions(el);
            }
          }
        }, this);
      }
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
    Loads a component. Config options:
    'name' (required) - the name of the child component to load
    'container' - the id of a panel with the 'fit' layout where the loaded widget will be instantiated
    'callback' - function that gets called after the component is loaded. It receives the component's instance as parameter.
    'scope' - scope for the callback.
    */
    loadComponent: function(params){
      if (params.id) {
        params.name = params.id;
        Netzke.deprecationWarning("Using 'id' in loadComponent is deprecated. Use 'name' instead.");
      }
      
      // params that will be provided for the server API call (deliver_component); all what's passed in params.params is merged in. This way we exclude from sending along such things as :scope, :callback, etc.
      var serverParams = params.params || {};
      serverParams.name = params.name;
      
      // Build the list of already loaded ("cached") classes
      serverParams.cache = [];
      
      for (var klass in Netzke.classes) {
        serverParams.cache.push(klass);
      }
      
      serverParams.cache = serverParams.cache.join();

      var storedConfig = this.componentsBeingLoaded[params.name] = {};

      // Remember where the loaded component should be inserted into
      if (params.container) {
        storedConfig.container = params.container;
      }

      // remember the passed callback for the future (per loaded component, as there may be simultaneous ongoing calls)
      if (params.callback) {
        storedConfig.callback = params.callback;
        storedConfig.scope = params.scope;
        // this.callbackHash[params.name.underscore()] = params.callback;
      }

      // remove the old component if the container is specified
      if (params.container) Ext.getCmp(params.container).removeChild();

      // do the remote API call
      this.deliverComponent(serverParams);
    },

    /*
    Called by the server after we ask him to load a component
    */
    componentDelivered : function(config){
      if (this.fireEvent('componentload'), config) {

        var storedConfig = this.componentsBeingLoaded[config.name] || {};
        delete this.componentsBeingLoaded[config.name];
      
        var componentInstance;
      
        if (storedConfig.container) {
          var container = Ext.getCmp(storedConfig.container);
          componentInstance = container.instantiateChild(config);
        } else {
          componentInstance = this.instantiateChild(config);
        }

        if (storedConfig.callback) {
          storedConfig.callback.call(storedConfig.scope || this, componentInstance);
        }
      }
    },

    /*
    Instantiates and inserts a component into a container with layout 'fit'.
    Arg: an JS object with the following keys:
      - id: id of the receiving container
      - config: configuration of the component to be instantiated and inserted into the container
    */
    // renderComponentInContainer : function(params){
    //   var cont = Ext.getCmp(params.container);
    //   if (cont) {
    //     cont.instantiateChild(params.config);
    //   } else {
    //     this.instantiateChild(params.config);
    //   }
    // },

    /*
    Returns the parent component
    */
    getParent: function(){
      // simply cutting the last part of the id: some_parent__a_kid__a_great_kid => some_parent__a_kid
      var idSplit = this.id.split("__");
      idSplit.pop();
      var parentId = idSplit.join("__");

      return parentId === "" ? null : Ext.getCmp(parentId);
    },

    /*
    Reloads current component (calls the parent to reload it as its component)
    */
    reload : function(){
      var parent = this.getParent();
      if (parent) {
        parent.loadComponent({id:this.localId(parent), container:this.ownerCt.id});
      } else {
        window.location.reload();
      }
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
    Reconfigures the component
    */
    reconfigure: function(config){
      this.ownerCt.instantiateChild(config)
    },

    /*
    Evaluates CSS
    */
    evalCss : function(code){
      var linkTag = document.createElement('style');
      linkTag.type = 'text/css';
      linkTag.innerHTML = code;
      document.body.appendChild(linkTag);
    },

    /*
    Evaluates JS
    */
    evalJs : function(code){
      eval(code);
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
            this[instr].apply(this, [instructions[instr]]); // execute the method
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

    // Get the child component
    getChildComponent : function(id){
      if (id === "") {return this};
      id = id.underscore();
      var split = id.split("__");
      if (split[0] === 'parent') {
        split.shift();
        var childInParentScope = split.join("__");
        return this.getParent().getChildComponent(childInParentScope);
      } else {
        return Ext.getCmp(this.id+"__"+id);
      }
    },

    // Common handler for all component's actions. <tt>comp</tt> is the Component that triggered the action (e.g. button or menu item)
    // actionHandler : function(comp){
    //   var actionName = comp.name;
    //   // If firing corresponding event doesn't return false, call the handler
    //   if (this.fireEvent(actionName+'click', comp)) {
    //     var action = this.actions[actionName];
    //     var customHandler = action.initialConfig.customHandler;
    //     var methodName = (customHandler && customHandler.camelize(true)) || "on" + actionName.camelize();
    //     if (!this[methodName]) {throw "Netzke: action handler '" + methodName + "' is undefined"}
    // 
    //     // call the handler passing it the triggering component
    //     this[methodName](comp);
    //   }
    // },
    // 
    // // Common handler for tools
    // toolActionHandler : function(tool){
    //   // If firing corresponding event doesn't return false, call the handler
    //   if (this.fireEvent(tool.id+'click')) {
    //     var methodName = "on"+tool.camelize();
    //     if (!this[methodName]) {throw "Netzke: handler for tool '"+tool+"' is undefined"}
    //     this[methodName]();
    //   }
    // },

    // Returns API url based on provided API point
    buildApiUrl: function(endpoint){
      Netzke.deprecationWarning("buildApiUrl() is deprecated. Use endpointUrl() first");
      return this.endpointUrl(endpoint);
    },
    
    endpointUrl: function(endpoint){
      return Netzke.RelativeUrlRoot + "/netzke/" + this.id + "__" + endpoint;
    },

    // Does the call to the server and processes the response
    callServer : function(intp, params, callback, scope){
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
    },

    setResult: function(result) {
      this.latestResult = result;
    },

    // At this moment component is fully initializied
    commonAfterConstructor : function(config){

      // Add the menus
      if (this.initialConfig.menu) {this.addMenu(this.initialConfig.menu, this);}

      // generic events
      this.addEvents(
        'componentload' // fired when a child is dynamically loaded
      );

      // Cleaning up on destroy
      this.on('beforedestroy', function(){
        this.cleanUpMenu();
      }, this);

      this.callbackHash = {};

      if (this.afterConstructor) this.afterConstructor(config);
    },

    feedback:function(msg){
      if (this.initialConfig && this.initialConfig.quiet) {
        return false;
      }

      if (this.feedbackGhost) {
        this.feedbackGhost.showFeedback(msg);
      } else {
        // there's no application to show the feedback - so, we do it ourselves
        if (typeof msg == 'string'){
          alert(msg);
        } else {
          var compoundResponse = "";
          Ext.each(msg, function(m){
            compoundResponse += m.msg + "\n"
          });
          if (compoundResponse != "") {
            alert(compoundResponse);
          }
        }
      }
    },

    // addMenu : function(menu, owner){
    //   if (!owner) {
    //     owner = this;
    //   }
    //   
    //   if (!!this.hostMenu) { 
    //     this.hostMenu(menu, owner); 
    //   } else {
    //     if (this.ownerComponent) {
    //       this.ownerComponent.addMenu(menu, owner);
    //     }
    //   }
    // },
    // 
    // cleanUpMenu : function(owner){
    //   if (!owner) {
    //     owner = this;
    //   }
    //   
    //   if (!!this.unhostMenu) { 
    //     this.unhostMenu(owner); 
    //   } else {
    //     if (this.ownerComponent) {
    //       this.ownerComponent.cleanUpMenu(owner);
    //     }
    //   }
    // },

    // Common handler for all component's actions. <tt>comp</tt> is the Component that triggered the action (e.g. button or menu item)
    actionHandler : function(comp){
      var actionName = comp.name;
      // If firing corresponding event doesn't return false, call the handler
      if (this.fireEvent(actionName+'click', comp)) {
        var action = this.actions[actionName];
        var customHandler = action.initialConfig.customHandler;
        var methodName = (customHandler && customHandler.camelize(true)) || "on" + actionName.camelize();
        if (!this[methodName]) {throw "Netzke: action handler '" + methodName + "' is undefined"}

        // call the handler passing it the triggering component
        this[methodName](comp);
      }
    },

    // Common handler for tools
    toolActionHandler : function(tool){
      // If firing corresponding event doesn't return false, call the handler
      if (this.fireEvent(tool.id+'click')) {
        var methodName = "on"+tool.camelize();
        if (!this[methodName]) {throw "Netzke: handler for tool '"+tool+"' is undefined"}
        this[methodName]();
      }
    },
    
    onComponentLoad:Ext.emptyFn // gets overridden
  }
}


// Netzke extensions for Ext.Container
Ext.override(Ext.Container, {
  // Instantiates an component by its config. If it appears to be a window, shows it instead of adding as item.
  // TODO: there must be a method to just instantiate a component, but not to add/show it instantly.
  instantiateChild : function(config){
    var instance = Ext.create(config);
    if (instance.isXType("window")) {
      instance.show();
    } else {
      this.remove(this.getNetzkeComponent()); // first delete previous component 
      this.add(instance);
      this.doLayout();
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
    this.remove(this.getNetzkeComponent());
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
      var msgCt = Ext.DomHelper.insertFirst(document.body, {'class':'netzke-feedback'}, true);
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
