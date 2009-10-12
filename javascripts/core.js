/*
This file gets loaded along with the rest of Ext library at the initial load
*/

Ext.BLANK_IMAGE_URL = "/extjs/resources/images/default/s.gif";
Ext.namespace('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.namespace('Netzke'); // namespace for extensions that do not depend on Ext
Ext.netzke.cache = {};

Ext.QuickTips.init(); // seems obligatory in Ext v2.2.1, otherwise Ext.Component#destroy() stops working properly

// To comply with Rails' forgery protection
Ext.Ajax.extraParams = {
  authenticity_token : Ext.authenticityToken
};

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

// Implementation of totalProperty, successProperty and root configuration options for ArrayReader
Ext.data.ArrayReader = Ext.extend(Ext.data.JsonReader, {
  readRecords : function(o){
    var sid = this.meta ? this.meta.id : null;
    var recordType = this.recordType, fields = recordType.prototype.fields;
    var records = [];
    var root = o[this.meta.root] || o, totalRecords = o[this.meta.totalProperty], success = o[this.meta.successProperty];
    for(var i = 0; i < root.length; i++){
      var n = root[i];
      var values = {};
      var id = ((sid || sid === 0) && n[sid] !== undefined && n[sid] !== "" ? n[sid] : null);
      for(var j = 0, jlen = fields.length; j < jlen; j++){
        var f = fields.items[j];
        var k = f.mapping !== undefined && f.mapping !== null ? f.mapping : j;
        var v = n[k] !== undefined ? n[k] : f.defaultValue;
        v = f.convert(v, n);
        values[f.name] = v;
      }
      var record = new recordType(values, id);
      record.json = n;
      records[records.length] = record;
    }
    return {
      records : records,
      totalRecords : totalRecords,
      success : success
    };
  }
});

// Properties/methods common to all widget classes
Ext.widgetMixIn = {
  height: 400,
  // width: 800,
  border: false,
  is_netzke: true, // to distinguish Netzke components from regular Ext components
  
  /*
  Loads aggregatee into a container.
  */
  loadAggregatee: function(params){
    // params that will be provided for the server API call (load_aggregatee_with_cache); all what's passed in params.params is merged in
    var apiParams = Ext.apply({id: params.id, container: params.container}, params.params); 
    
    // build the cached widgets list to send it to the server
    var cachedWidgetNames = [];
    for (name in Ext.netzke.cache) {
      cachedWidgetNames.push(name);
    }
    apiParams.cache = Ext.encode(cachedWidgetNames);
    
    // remember the passed callback for the future
    if (params.callback) {
      this.callbackHash[params.id] = params.callback; // per loaded widget, as there may be simultaneous calls
    }
    
    // visually disable the container while the widget is being loaded
    // Ext.getCmp(params.container).disable();

    Ext.getCmp(params.container).removeChild(); // remove the old widget
    
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
    cont.instantiateChild(params.config);
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
  
  // Common handler for actions
  actionHandler : function(action){
    // If firing corresponding event doesn't return false, call the handler
    if (this.fireEvent(action.name+'click', action)) {
      var methodName = action.fn || "on"+action.name.camelize();
      if (!this[methodName]) {throw "Netzke: handler for action '" + action.name + "' is undefined"}
      this[methodName](action);
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

  // Does the call to the server and processes the response
  callServer : function(intp, params, callback, scope){
    if (!params) params = {};
    Ext.Ajax.request({
      params : params,
      url : this.id + "__" + intp,
      callback : function(options, success, response){
        if (success) {
          // execute commands from server
          this.bulkExecute(Ext.decode(response.responseText));
          
          // provade callback if needed
          if (typeof callback == 'function') { 
            if (!scope) scope = this;
            callback.apply(scope);
          }
        }
      },
      scope : this
    });
  },

  /* Parse the bbar and tbar (both Arrays), replacing the strings with the corresponding methods. For example:
    replaceStringsWithActions( ['add', {text:'Menu', menu:['edit', 'delete']}] )
    => [scope.actions['add'], {text:'Menu', menu:[scope.actions['edit'], scope.actions['delete']]}]
  */
  normalizeMenuItems: function(arry, scope){
    var res = []; // new array
    Ext.each(arry, function(o){
      if (typeof o === "string") {
        var camelized = o.camelize(true);
        if (scope.actions[camelized]){
          res.push(scope.actions[camelized]);
        } else {
          // if there's no action with this name, maybe it's a separator or something
          res.push(o);
        }
      } else if (Netzke.isObject(o)) {
        // look inside the objects...
        for (var key in o) {
          if (Ext.isArray(o[key])) {
            // ... and recursively process inner arrays found
            o[key] = this.normalizeMenuItems(o[key], scope);
          }
        }
        res.push(o);
      }
    }, this);
    return res;
  },
  

  // Every Netzke widget 
  commonBeforeConstructor : function(config){
    this.actions = {};

    // Generate methods for api points
    if (!config.api) { config.api = []; }
    config.api.push('load_aggregatee_with_cache'); // all netzke widgets get this API
    Ext.each(config.api, function(intp){
      this[intp.camelize(true)] = function(args, callback, scope){ this.callServer(intp, args, callback, scope); }
    }, this);

    // Create Ext.Actions based on config.actions
    if (config.actions) {
      this.testActions = {};
      for (var name in config.actions) {
        // Create an event for each action (so that higher-level widgets could interfere)
        this.addEvents(name+'click');

        // Configure the action
        var actionConfig = config.actions[name];
        actionConfig.handler = this.actionHandler.createDelegate(this);
        actionConfig.name = name;
        this.actions[name] = new Ext.Action(actionConfig);
      }

      config.bbar = config.bbar && this.normalizeMenuItems(config.bbar, this);
      config.tbar = config.tbar && this.normalizeMenuItems(config.tbar, this);
      config.menu = config.menu && this.normalizeMenuItems(config.menu, this);
      config.contextMenu = config.contextMenu && this.normalizeMenuItems(config.contextMenu, this);
      
      // TODO: need to rethink this action related stuff
      config.actions = this.actions;
      
    }

    // Normalize tools
    if (config.tools) {
      var normTools = [];
      Ext.each(config.tools, function(tool){
        // Create an event for each action (so that higher-level widgets could interfere)
        this.addEvents(tool.id+'click');

        var handler = this.toolActionHandler.createDelegate(this, [tool]);
        normTools.push({id : tool, handler : handler, scope : this});
      }, this);
      config.tools = normTools;
    }
    
    // Set title
    if (!config.title) config.title = config.id.humanize();
  },

  // At this moment component is fully initializied
  commonAfterConstructor : function(config){
    // From everywhere accessible FeedbackGhost
    this.feedbackGhost = Ext.getCmp('feedback_ghost');

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

  addMenu : function(menu, owner){
    if (!owner) {
      owner = this;
    }
    
    if (!!this.hostMenu) { 
      this.hostMenu(menu, owner); 
    } else {
      if (this.ownerWidget) {
        this.ownerWidget.addMenu(menu, owner);
      }
    }
  },
  
  cleanUpMenu : function(owner){
    if (!owner) {
      owner = this;
    }
    
    if (!!this.unhostMenu) { 
      this.unhostMenu(owner); 
    } else {
      if (this.ownerWidget) {
        this.ownerWidget.cleanUpMenu(owner);
      }
    }
  },
  
  onWidgetLoad:Ext.emptyFn // gets overridden
};

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
  
  removeChild : function(){
    this.remove(this.getWidget());
  },

  instantiateChild : function(config){
    this.remove(this.getWidget()); // first delete previous widget 

    if (!config) return false; // simply remove current widget if null is passed

    var instance = new Ext.netzke.cache[config.widgetClassName](config);
    this.add(instance);
    this.doLayout();
  }
});