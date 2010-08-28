Ext.ns("Netzke.modules");
Netzke.modules.Actions = {
  initComponentWithActions : function(){
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
    
    // Detect menus recursively among our properties, and normalize them
    this.detectMenus(this);
    
    // Call original initComponent
    this.initComponentWithoutActions();
  },

  detectMenus : function(o) {
    var keyWords = ["bbar", "tbar", "fbar"];
    if (Ext.isObject(o)) {
      Ext.each(keyWords, function(key){
        if (o[key]) { 
          o[key] = this.normalizeMenuItems(o[key], this); 
        };
      }, this);
      
      for (var key in o) {
        if (keyWords.indexOf(key) == -1) {
          this.detectMenus(o[key]);
        }
      }
    } else if (Ext.isArray(o)) {
      Ext.each(o, function(el){
        this.detectMenus(el);
      }, this);
    }
    
  },

  /* Normalize an array of abstracted button configs into an array of Ext button configs according to the following rules:
    - if the element is a string and <tt>scope</tt> has an action with this name, replace this element with that action; if <tt>scope</tt> has no corresponding action, don't do anything (Ext will take care of it - display as text, or a separator, etc)
    - if the element is an object, then:
    -- if this object has a <tt>menu</tt> property - it's a nested menu; the value is expected to be an array of abstracted button configs, so, proceed recursively.
    -- if this object has a <tt>handler</tt> property and the value correspond to a function in <tt>scope</tt> - replace this value with the reference to that function
  */
  normalizeMenuItems : function(arry, scope){
    var res = []; // new array
    Ext.each(arry, function(o){
      if (typeof o === "string") {
        var camelized = o.camelize(true);
        if (scope.actions[camelized]){
          res.push(scope.actions[camelized]);
        } else {
          // if there's no action with this name, maybe it's a separator or text or whatever
          res.push(o);
        }
      } else if (Netzke.isObject(o)) {
        // look inside the objects...
        if (o.menu) {
          // ... and recursively process nested menus
          o.menu = this.normalizeMenuItems(o.menu, scope);
        } else if (o.handler && Ext.isFunction(scope[o.handler.camelize(true)])) {
          // This button config has a handler specified as string - replace it with reference to a real function if it exists
          o.handler = scope[o.handler.camelize(true)];
        }
        res.push(o);
      }
    }, this);

    delete arry;

    return res;
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
  },

  
}