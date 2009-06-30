/*
This file gets loaded along with the rest of Ext library at the initial load
*/

Ext.BLANK_IMAGE_URL = "/extjs/resources/images/default/s.gif";
Ext.namespace('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.namespace('Netzke'); // namespace for extensions that do not depend on Ext
Ext.netzke.cache = {};

Ext.QuickTips.init(); // seems obligatory in Ext v2.2.1, otherwise Ext.Component#destroy() stops working properly

// to comply with Rails' forgery protection
Ext.Ajax.extraParams = {
  authenticity_token : Ext.authenticityToken
};

// helper method to do multiple Ext.apply's
Ext.netzke.chainApply = function(objectArray){
  var res = {};
  Ext.each(objectArray, function(obj){Ext.apply(res, obj)});
  return res;
};

// Type detection functions
Netzke.isObject = function(o) {
  return (o != null && typeof o == "object" && o.constructor.toString() == Object.toString());
}

// Some Rubyish String extensions
// from http://code.google.com/p/inflection-js/
String.prototype.camelize=function(lowFirstLetter)
{
  var str=this.toLowerCase();
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
    // console.info(this.meta);
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

// Methods common to all widget classes
Ext.widgetMixIn = {
  /*
  Instantiates and inserts a widget into a container with layout 'fit'.
  Arg: an JS object with the following keys:
    - id: id of the receiving container
    - config: configuration of the widget to be instantiated and inserted into the container
  */
  renderWidgetInContainer : function(params){
    var cont = Ext.getCmp(params.id);
    cont.instantiateChild(params.config);
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
  Executes a bunch of methods. This method is called everytime a communication to the server takes place. Thus the server side of a widget can provide any set of commands to its client side!
  Args:
    - methods: array of methods, in the order of execution. Each item is an object in one of the following 2 formats:
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
  bulkExecute : function(methods){
    Ext.each(methods, function(methodSet){
      if (methodSet.widget) {
        this.getChildWidget(methodSet.widget).bulkExecute(methodSet.methods);
      } else {
        for (var method in methodSet) {
          this[method].apply(this, [methodSet[method]]);
          // this[method].apply(this, Ext.isArray(methodSet[method]) ? methodSet[method] : [methodSet[method]]);
        }
      }
    }, this);
  },
  
  // Get the child widget
  getChildWidget : function(id){
    return Ext.getCmp(this.id+"__"+id);
  },
  
  // Common handler for actions
  actionHandler : function(action){
    // If firing corresponding event doesn't return false, call the handler
    if (this.fireEvent(action.name+'click', action)) {
      this[(action.fn || action.name)](action);
    }
  },

  // Common handler for tools
  toolActionHandler : function(tool){
    // If firing corresponding event doesn't return false, call the handler
    if (this.fireEvent(tool.id+'click')) {
      this[tool]();
    }
  },

  // Does the call to the server and processes the response
  callServer : function(intp, params){
    if (!params) params = {};
    Ext.Ajax.request({
      params : params,
      url : this.id + "__" + intp,
      callback : function(options, success, response){
        if (success) this.bulkExecute(Ext.decode(response.responseText));
      },
      scope : this
    });
  },

  beforeConstructor : function(config){
    this.actions = {};

    // Create methods for interface points
    if (config.interface){
      Ext.each(config.interface, function(intp){
        // intp = "update_panels";
        // eval("this[intp.camelize(true)] = function(args){ alert('"+intp+"') }");
        this[intp.camelize(true)] = function(args){ this.callServer(intp, args); }
        // eval("this[intp.camelize(true)] = function(args){ this.callServer('"+intp+"', args); }");
      }, this);
    }

    // Create Ext.Actions based on config.actions
    if (config.actions) {
      for (var name in config.actions) {
        // Create an event for each action (so that higher-level widgets could interfere)
        this.addEvents(name+'click');

        // Configure the action
        var actionConfig = config.actions[name];
        actionConfig.handler = this.actionHandler.createDelegate(this);
        actionConfig.name = name;
        this.actions[name] = new Ext.Action(actionConfig);
      }

      /* Parse the bbar and tbar (both Arrays), replacing the strings with the corresponding methods. For example:
        replaceStringsWithActions( ['add', {text:'Menu', menu:['edit', 'delete']}] )
        => [scope.actions['add'], {text:'Menu', menu:[scope.actions['edit'], scope.actions['delete']]}]
      */
      var replaceStringsWithActions = function(arry, scope){
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
                o[key] = replaceStringsWithActions(o[key], scope);
              }
            }
            res.push(o);
          }
        });
        return res;
      }
      config.bbar = config.bbar && replaceStringsWithActions(config.bbar, this);
      config.tbar = config.tbar && replaceStringsWithActions(config.tbar, this);
      config.menu = config.menu && replaceStringsWithActions(config.menu, this);
      
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
    
  },

  afterConstructor : function(config){
    this.feedbackGhost = Ext.getCmp('feedback_ghost');

    // cleaning up
    this.on('beforedestroy', function(){
      this.cleanUpMenu(this);
    }, this);
    
    // After render, add the menus
    this.on('render', function(){
      if (this.initialConfig.menu) {this.addMenu(this.initialConfig.menu);}
    }, this);

    this.on('render', this.onWidgetLoad, this);
  },

  // Set size of this component by resizing the fit panel it belongs to
  // TODO: implement more related functions when needed, like setSize, setPosition, etc
  // setWidth : function(w){
  //   this.ownerCt.setWidth(w);
  // },
  // setHeight : function(h){
  //   this.ownerCt.setHeight(h);
  // },

  // Each widget can provide feedback to the user
  // setFeedback : function(msg){
  //   this.feedback(msg);
  // },
  
  // for backward compatibility
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
    Get Netzke widget that this Ext.Container is part of. 
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
    return this.items.get(0);
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

// Make Panel with layout 'fit' capable of dynamic widgets loading
Ext.override(Ext.Panel, {
  // Load a new hosted widget from the server
  loadWidgetOBSOLETE: function(url, params){
    if (!params) {
      params = {};
    }
    
    this.remove(this.getWidget()); // first delete previous widget 
    
    if (!url) return false; // don't load any widget if the url is null

    // we will let the server know which components we have cached
    var cachedComponentNames = [];
    for (name in Ext.netzke.cache) {
      cachedComponentNames.push(name);
    }
    
    this.disable(); // to visually emphasize loading
    
    Ext.Ajax.request({
        url:url, 
        params:Ext.apply(params, {components_cache:Ext.encode(cachedComponentNames)}), 
        script:false,
        callback:function(panel, success, response){
          var responseObj = Ext.decode(response.responseText);
          if (responseObj.config) {
            // we got a normal response

            // evaluate widget's stylesheets
            if (responseObj.css){
              var linkTag = document.createElement('style');
              linkTag.type = 'text/css';
              linkTag.innerHTML = responseObj.css;
              document.body.appendChild(linkTag);
            }
            
            // evaluate widget's javascript
            if (responseObj.js) {
              eval(responseObj.js);
            }
          
            responseObj.config.ownerWidget = this.getOwnerWidget();
            // var instance = new Ext.netzke.cache[responseObj.config.widgetClassName](responseObj.config);
            //         
            // this.add(instance);
            // this.doLayout();
            this.instantiateChild(responseObj.config);
          } else {
            // we didn't get normal response - desplay the flash with eventual errors
            this.getOwnerWidget().feedback(responseObj.flash);
          }
          
          // reenable the panel
          this.enable();
        },
        scope:this
    })
  }
});

