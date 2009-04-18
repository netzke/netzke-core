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

  beforeConstructor : function(config){
    this.actions = {};

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
  }
});

// Make Panel with layout 'fit' capable of dynamic widgets loading
Ext.override(Ext.Panel, {
  getWidget: function(){
    return this.items.get(0);
  },
  
  loadWidget: function(url, params){
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
            var instance = new Ext.netzke.cache[responseObj.config.widgetClassName](responseObj.config)
        
            this.add(instance);
            this.doLayout();
            
          } else {
            // we didn't get normal response - desplay the flash with eventual errors
            this.ownerCt.feedback(responseObj.flash);
          }
          
          // reenable the panel
          this.enable();
        },
        scope:this
    })
  }
});

