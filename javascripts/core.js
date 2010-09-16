/*
This file gets loaded along with the rest of Ext library at the initial load
*/

// Check Ext JS version
(function(){
  var requiredExtVersion = "3.2.1";
  var currentExtVersion = Ext.version;
  if (requiredExtVersion !== currentExtVersion) {
    alert("Netzke needs Ext " + requiredExtVersion + ". You have " + currentExtVersion + ".");
  }
})();

// Initial stuff
Ext.BLANK_IMAGE_URL = "/extjs/resources/images/default/s.gif";
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.ns('Netzke'); // Netzke namespace
Ext.ns('Netzke.page'); // namespace for all widget instantces on the page
Ext.ns('Netzke.classes'); // namespace for all widget classes. TODO: this should be called Netzke.Widget

Ext.QuickTips.init();

// We don't want no state managment by default, thank you!
Ext.state.Provider.prototype.set = function(){};

// Type detection functions
Netzke.isObject = function(o) {
  return (o != null && typeof o == "object" && o.constructor.toString() == Object.toString());
}

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

// Properties/methods common to all widget classes
Ext.widgetMixIn = function(receiver){
  
  return {
    height: 400,
    // width: 800,
    border: false,
    isNetzke: true, // to distinguish Netzke components from regular Ext components
    latestResult: {}, // latest result returned from the server via an API call

    aliasMethodChain : function(target, feature) {
      this[target + "Without" + feature.capitalize()] = this[target];
      this[target] = this[target + "With" + feature.capitalize()];
    },

    /*
    Loads aggregatee into a container.
    */
    loadAggregatee: function(params){
      // params that will be provided for the server API call (load_aggregatee_with_cache); all what's passed in params.params is merged in. This way we exclude from sending along such things as :scope, :callback, etc.
      var apiParams = Ext.apply({id: params.id, container: params.container}, params.params); 

      // build the cached widgets list to send it to the server
      var cachedWidgetNames = "";

      // recursive function that checks the properties of the caller ("this") and returns the list of those that look like constructor, i.e. have an "xtype" property themselves
      var classesList = function(pref){
        var res = [];
        for (name in this) {
          if (this[name].xtype) {
            res.push(pref + name);
            this[name].classesList = classesList; // define the same function on each property on the fly
            res = res.concat(this[name].classesList(pref + name + ".")); // ... and call it, providing our name along with the scope
          }
        }
        return res;
      };

      // assign this function to Netzke.classes and call it
      Netzke.classes.classesList = classesList;
      var cl = Netzke.classes.classesList("");

      // join the classes into a coma-separated list
      var cache = "";
      Ext.each(cl, function(c){cache += c + ",";});

      // for (name in Netzke.classes) {
      //   cachedWidgetNames += name + ",";
      // }
      // apiParams.cache = cachedWidgetNames;
      apiParams.cache = cache;

      // remember the passed callback for the future
      if (params.callback) {
        this.callbackHash[params.id] = params.callback; // per loaded widget, as there may be simultaneous calls
      }

      // visually disable the container while the widget is being loaded
      // Ext.getCmp(params.container).disable();

      if (params.container) Ext.getCmp(params.container).removeChild(); // remove the old widget if the container is specified

      // do the remote API call
      this.loadAggregateeWithCache(apiParams);
    },

    /*
    Called by the server as callback about loaded widget
    */
    widgetLoaded : function(params){
      if (this.fireEvent('widgetload')) {
        // Enable the container after the widget is succesfully loaded
        // this.getChildWidget(params.id).ownerCt.enable();

        // provide the callback to that widget that was loading the child, passing the child itself
        var callbackFn = this.callbackHash[params.id.camelize(true)];
        if (callbackFn) {
          callbackFn.call(params.scope || this, this.getChildWidget(params.id));
          delete this.callbackHash[params.id.camelize(true)];
        }
      }
    },

    /*
    Returns the parent widget
    */
    getParent: function(){
      // simply cutting the last part of the id: some_parent__a_kid__a_great_kid => some_parent__a_kid
      var idSplit = this.id.split("__");
      idSplit.pop();
      var parentId = idSplit.join("__");

      return parentId === "" ? null : Ext.getCmp(parentId);
    },

    /*
    Reloads current widget (calls the parent to reload it as its aggregatee)
    */
    reload : function(){
      var parent = this.getParent();
      if (parent) {
        parent.loadAggregatee({id:this.localId(parent), container:this.ownerCt.id});
      } else {
        window.location.reload();
      }
    },

    /*
    Gets id in the context of provided parent. 
    For example, the widgets "properties", being a child of "books" has global id "books__properties", 
    which *is* its widegt's real id. This methods, with the instance of "books" passed as parameter, 
    returns "properties".
    */
    localId : function(parent){
      return this.id.replace(parent.id + "__", "");
    },

    /*
    Instantiates and inserts a widget into a container with layout 'fit'.
    Arg: an JS object with the following keys:
      - id: id of the receiving container
      - config: configuration of the widget to be instantiated and inserted into the container
    */
    renderWidgetInContainer : function(params){
      var cont = Ext.getCmp(params.container);
      if (cont) {
        cont.instantiateChild(params.config);
      } else {
        this.instantiateChild(params.config);
      }
    },

    /*
    Reconfigures the widget
    */
    reconfigure: function(config){
      this.ownerCt.instantiateChild(config)
    },

    /*
    Evaluates CSS
    */
    css : function(code){
      var linkTag = document.createElement('style');
      linkTag.type = 'text/css';
      linkTag.innerHTML = code;
      document.body.appendChild(linkTag);
    },

    /*
    Evaluates JS
    */
    js : function(code){
      eval(code);
    },

    /*
    Executes a bunch of methods. This method is called almost every time a communication to the server takes place. 
    Thus the server side of a widget can provide any set of commands to its client side.
    Args:
      - instructions: array of methods, in the order of execution. 
        Each item is an object in one of the following 2 formats:
          1) {method1:args1, method2:args2}, where methodN is a name of a public method of this widget; these methods are called in no particular order
          2) {widget:widget_id, methods:arrayOfMethods}, used for recursive call to bulkExecute on some child widget

    Example: 
      - [
          // the same as this.feedback("Your order is accepted")
          {feedback: "You order is accepted"}, 

          // the same as this.getChildWidget('users').bulkExecute([{setTitle:'Suprise!'}, {setDisabled:true}])
          {widget:'users', methods:[{setTitle:'Suprise!'}, {setDisabled:true}] },

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
          if (this[instr]) {
            this[instr].apply(this, [instructions[instr]]);
          } else {
            var childWidget = this.getChildWidget(instr);
            if (childWidget) {
              childWidget.bulkExecute(instructions[instr]);
            } else {
              throw "Netzke: Unknown method or child widget '" + instr +"' in widget '" + this.id + "'"
            }
          }
        }
      }
    },

    // Get the child widget
    getChildWidget : function(id){
      if (id === "") {return this};

      var split = id.split("__");
      if (split[0] === 'parent') {
        split.shift();
        var childInParentScope = split.join("__");
        return this.getParent().getChildWidget(childInParentScope);
      } else {
        return Ext.getCmp(this.id+"__"+id);
      }
    },

    // Common handler for all widget's actions. <tt>comp</tt> is the Component that triggered the action (e.g. button or menu item)
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
    buildApiUrl: function(apip){
      return "/netzke/" + this.id + "__" + apip;
    },

    // Does the call to the server and processes the response
    callServer : function(intp, params, callback, scope){
      if (!params) params = {};
        Ext.Ajax.request({
        params: params,
        url: this.buildApiUrl(intp),
        callback: function(options, success, response){
          if (success) {
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

    initComponentWithNetzke : function() {
      this.normalizeActions();
      
      // Detect menus recursively among our properties, and normalize them
      // this.detectMenus(this);
      this.detectActions(this);
      
      // Recursively detect aggregatees
      this.detectAggregatees(this.items);
      
      // Dynamically create methods for api points, so that we could later call them like: this.myApiMethod()
      var config = this;
      var apiPoints = config.netzkeApi || [];
      apiPoints.push('load_aggregatee_with_cache'); // all netzke widgets get this API point
      Ext.each(apiPoints, function(intp){
        this[intp.camelize(true)] = function(args, callback, scope){ this.callServer(intp, args, callback, scope); }
      }, this);

      // that's where the references to different callback functions will be stored
      this.callbackHash = {};
      
      // call the original method
      this.initComponentWithoutNetzke();
    },

    // Code run before calling Ext's constructor - normalizing config to provide Netzke additional functionality
    // commonBeforeConstructor : function(config){

      // This will contain Ext.Action instances
      // this.actions = {};

      // Create Ext.Action instances based on config.actions
      // if (config.actions) {
      //   for (var name in config.actions) {
      //     // Create an event for each action (so that higher-level widgets could interfere)
      //     this.addEvents(name+'click');
      // 
      //     // Configure the action
      //     var actionConfig = config.actions[name];
      //     actionConfig.customHandler = actionConfig.handler || actionConfig.fn; //DEPRECATED: .fn is kept for backward compatibility, preferred way is to specify handler
      //     actionConfig.handler = this.actionHandler.createDelegate(this); // ! this is the "wrapper-handler", which is common for all actions!
      //     actionConfig.name = name;
      //     this.actions[name] = new Ext.Action(actionConfig);
      //   }
      //   
      //   // TODO: need to rethink this action related stuff
      //   config.actions = this.actions;
      // }
      // 
      // config.bbar = config.bbar && this.normalizeMenuItems(config.bbar, this);
      // config.tbar = config.tbar && this.normalizeMenuItems(config.tbar, this);
      // config.fbar = config.fbar && this.normalizeMenuItems(config.fbar, this);
      // config.contextMenu = config.contextMenu && this.normalizeMenuItems(config.contextMenu, this);

      // config.menu = config.menu && this.normalizeMenuItems(config.menu, this);

      // Normalize tools
      // if (config.tools) {
      //   var normTools = [];
      //   Ext.each(config.tools, function(tool){
      //     // Create an event for each action (so that higher-level widgets could interfere)
      //     this.addEvents(tool.id+'click');
      // 
      //     var handler = this.toolActionHandler.createDelegate(this, [tool]);
      //     normTools.push({id : tool, handler : handler, scope : this});
      //   }, this);
      //   config.tools = normTools;
      // }

      // Set title
      // if (config.mode === "config"){
      //   if (!config.title) {
      //     config.title = '[' + config.id + ']';
      //   } else {
      //     config.title = config.title + ' [' + config.id + ']';
      //   }
      // } else {
      //   if (!config.title) {
      //     config.title = config.id.humanize();
      //   }
      // }
    // },

    // At this moment component is fully initializied
    commonAfterConstructor : function(config){
      // From everywhere accessible FeedbackGhost
      this.feedbackGhost = new Netzke.FeedbackGhost();

      // Add the menus
      if (this.initialConfig.menu) {this.addMenu(this.initialConfig.menu, this);}

      // generic events
      this.addEvents(
        'widgetload' // fired when a child is dynamically loaded
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
    //     if (this.ownerWidget) {
    //       this.ownerWidget.addMenu(menu, owner);
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
    //     if (this.ownerWidget) {
    //       this.ownerWidget.cleanUpMenu(owner);
    //     }
    //   }
    // },

    onWidgetLoad:Ext.emptyFn // gets overridden
  }
}


// Netzke extensions for Ext.Container
Ext.override(Ext.Container, {
  /** 
    Get Netzke widget that this Ext.Container is part of (*not* the parent widget, for which call getParent)
    It searches up the Ext.Container hierarchy until it finds a Container that has isNetzke property set to true
    (or until it reaches the top).
  */
  getOwnerWidget : function(){
    if (this.initialConfig.isNetzke) {
      return this;
    } else {
      if (this.ownerCt){
        return this.ownerCt.getOwnerWidget()
      } else {
        return null
      }
    }
  },
  
  // Get the widget that we are hosting
  getWidget: function(){
    return this.items ? this.items.get(0) : null; // need this check in case when the container is not yet rendered, like an inactive tab in the TabPanel
  },
  
  // Remove the child
  removeChild : function(){
    this.remove(this.getWidget());
  },

  // Given a scoped class name, returns the actual class, e.g.: "Netzke.GridPanel" => Netzke.classes.Netzke.GridPanel
  classifyScopedName : function(n){
    var klass = Netzke.classes;
    Ext.each(n.split("."), function(s){
      klass = klass[s];
    });
    return klass;
  },

  // Instantiates an aggregatee by its config. If it appears to be a window, shows it instead of adding as item.
  instantiateChild : function(config){
    var klass = this.classifyScopedName(config.scopedClassName);
    var instance = new klass(config);
    if (instance.isXType("netzkewindow")) {
      instance.show();
    } else {
      this.remove(this.getWidget()); // first delete previous widget 
      this.add(instance);
      this.doLayout();
    }
  },
  
  /*
  Actions, menus, toolbars
  */
  normalizeActions : function(){
    // Normalize actions
    var normActions = {};
    for (var name in this.actions) {
      // Create an event for each action (so that higher-level widgets could interfere)
      this.addEvents(name+'click');

      // Configure the action
      var actionConfig = this.actions[name];
      actionConfig.customHandler = actionConfig.handler || actionConfig.fn; //DEPRECATED: .fn is kept for backward compatibility, preferred way is to specify handler
      actionConfig.handler = this.actionHandler.createDelegate(this); // ! this is the "wrapper-handler", which is common for all actions!
      actionConfig.name = name;
      normActions[name] = new Ext.Action(actionConfig);
    }
    delete(this.actions);
    this.actions = normActions;
  },

  /*
  Detects action configs in the object, and replaces them with instances of Ext.Action.
  
  Example of 'this':
  this: {
    actions: {action1: new Ext.Action(1), action2: new Ext.Action(2), ...}, // actions are instantiated in the scope of this.actions
    bbar: [{action:'action1'}, {action:'action2'}, ...] // these are the action configs, and they correspond to the "actions" property in "this"
  }
  */
  detectActions: function(o){
    if (Ext.isObject(o)) {
      Ext.each(["bbar", "tbar", "fbar", "menu", "items"], function(key){
        if (o[key]) this.detectActions(o[key]);
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
        } else if (Ext.isArray(el)) {
          this.detectActions(el);
        }
      }, this);
    }
  },

  detectAggregatees: function(o){
    if (Ext.isObject(o)) {
      if (o.items) this.detectAggregatees(o.items);
    } else if (Ext.isArray(o)) {
      var a = o;
      Ext.each(a, function(el, i){
        if (el.aggregatee) {
          a[i] = Ext.apply(this.aggregatees[el.aggregatee.camelize(true)], el);
          delete a[i].aggregatee;
        } else if (el.items) this.detectAggregatees(el.items);
      }, this);
    }
  },

  // Common handler for all widget's actions. <tt>comp</tt> is the Component that triggered the action (e.g. button or menu item)
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
