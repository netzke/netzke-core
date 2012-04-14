// Enable Ext 4 migration errors traceback display
if (Ext.Compat) Ext.Compat.showErrors = true;

// Because of Netzke's double-underscore notation, Ext.TabPanel should have a different id-delimiter (yes, this should be in netzke-core)
Ext.TabPanel.prototype.idDelimiter = "___";

Ext.QuickTips.init();

// We don't want no state managment by default, thank you!
Ext.state.Provider.prototype.set = Ext.emptyFn;

// Checking Ext JS version: both major and minor versions must be the same
(function(){
  var requiredVersionMajor = 4,
      requiredVersionMinor = 0,
      extVersion = Ext.getVersion('extjs'),
      currentVersionMajor = extVersion.getMajor(),
      currentVersionMinor = extVersion.getMinor(),
      requiredString = "" + requiredVersionMajor + "." + requiredVersionMinor + ".x",
      currentString = "" + currentVersionMajor + "." + currentVersionMinor + ".x";

  if (requiredVersionMajor != currentVersionMajor || requiredVersionMinor != currentVersionMinor) {
    Netzke.warning("Ext " + requiredString + " required. You have " + currentString + ".");
  }
})();

// FeedbackGhost is a little class that displays unified feedback from Netzke components.
Ext.define('Netzke.FeedbackGhost', {
  showFeedback: function(msg){
    if (!msg) Netzke.exception("Netzke.FeedbackGhost#showFeedback: wrong number of arguments (0 for 1)");
    if (Ext.isObject(msg)) {
      this.msg(msg.level.camelize(), msg.msg);
    } else if (Ext.isArray(msg)) {
      Ext.each(msg, function(m) { this.showFeedback(m); }, this);
    } else {
      this.msg(null, msg); // no header for now
    }
  },

  msg: function(title, format){
      if(!this.msgCt){
          this.msgCt = Ext.core.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
      }
      var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
      var m = Ext.core.DomHelper.append(this.msgCt, this.createBox(title, s), true);
      m.hide();
      m.slideIn('t').ghost("t", { delay: 1000, remove: true});
  },

  createBox: function(t, s){
    if (t) {
      return '<div class="msg"><h3>' + t + '</h3><p>' + s + '</p></div>';
    } else {
      return '<div class="msg"><p>' + s + '</p></div>';
    }
  }
});

// Mix it into every Netzke component as feedbackGhost
Netzke.componentMixin.feedbackGhost = Ext.create("Netzke.FeedbackGhost");

Ext.define('Netzke.classes.NetzkeRemotingProvider', {
  extend: 'Ext.direct.RemotingProvider',

  getCallData: function(t){
    return {
      act: t.action, // rails doesn't really support having a parameter named "action"
      method: t.method,
      data: t.data,
      type: 'rpc',
      tid: t.id
    }
  },

  addAction: function(action, methods) {
    var cls = this.namespace[action] || (this.namespace[action] = {});
    for(var i = 0, len = methods.length; i < len; i++){
      method = Ext.create('Ext.direct.RemotingMethod', methods[i]);
      cls[method.name] = this.createHandler(action, method);
    }
  },

  // HACK: Ext JS 4.0.0 retry mechanism is broken
  getTransaction: function(opt) {
    if (opt.$className == "Ext.direct.Transaction") {
      return opt;
    } else {
      return this.callParent([opt]);
    }
  }
});

Netzke.directProvider = new Netzke.classes.NetzkeRemotingProvider({
  type: "remoting",       // create a Ext.direct.RemotingProvider
  url: Netzke.RelativeUrlRoot + "/netzke/direct/", // url to connect to the Ext.Direct server-side router.
  namespace: "Netzke.providers", // namespace to create the Remoting Provider in
  actions: {},
  maxRetries: Netzke.core.directMaxRetries,
  enableBuffer: true, // buffer/batch requests within 10ms timeframe
  timeout: 30000 // 30s timeout per request
});

Ext.Direct.addProvider(Netzke.directProvider);

// Methods/properties that each and every Netzke component will have
Ext.apply(Netzke.classes.Core.Mixin, {
  /*
  Mask shown during loading of a component. Set to false to not mask. Pass config for Ext.LoadMask for configuring msg/cls, etc.
  Set msg to null if mask without any msg is desirable.
  */
  componentLoadMask: true,

  /* initComponent common for all Netzke components */
  initComponentWithNetzke: function(){
    this.normalizeActions();

    this.detectActions(this);

    // Detects component placeholders in the passed object (typically, "items"),
    // and merges them with the corresponding config from this.netzkeComponents.
    // This way it becomes ready to be instantiated properly by Ext.
    this.detectComponents(this.items);

    this.normalizeTools();

    this.processEndpoints();

    this.processPlugins();

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

    // Call the original initComponent
    this.initComponentWithoutNetzke();
  },

  /*
  Dynamically creates methods for endpoints, so that we could later call them like: this.myEndpointMethod()
  */
  processEndpoints: function(){
    var endpoints = this.endpoints || [];
    endpoints.push('deliver_component'); // all Netzke components get this endpoint
    var directActions = [];
    var that = this;

    Ext.each(endpoints, function(intp){
      console.log("intp:", intp);
      directActions.push({"name":intp.camelize(true), "len":1});
      this[intp.camelize(true)] = function(arg, callback, scope) {
        Netzke.runningRequests++;

        scope = scope || that;
        Netzke.providers[this.id][intp.camelize(true)].call(scope, arg, function(result, remotingEvent) {
          if(remotingEvent.message) {
            console.error("RPC event indicates an error: ", remotingEvent);
            throw new Error(remotingEvent.message);
          }
          that.bulkExecute(result); // invoke the endpoint result on the calling component
          if(typeof callback == "function") {
            callback.call(scope, that.latestResult); // invoke the callback on the provided scope, or on the calling component if no scope set. Pass latestResult to callback
          }
          Netzke.runningRequests--;
        });
      }
    }, this);

    Netzke.directProvider.addAction(this.id, directActions);
  },

  normalizeTools: function() {
    if (this.tools) {
      var normTools = [];
      Ext.each(this.tools, function(tool){
        // Create an event for each action (so that higher-level components could interfere)
        this.addEvents(tool.id+'click');

        var handler = Ext.Function.bind(this.toolActionHandler, this, [tool]);
        normTools.push({type : tool, handler : handler, scope : this});
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
      var actionConfig = Ext.apply({}, this.actions[name]); // do not modify original this.actions
      actionConfig.customHandler = actionConfig.handler;
      actionConfig.handler = Ext.Function.bind(this.actionHandler, this); // handler common for all actions
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
      Ext.each(["bbar", "tbar", "fbar", "menu", "items", "contextMenu", "buttons", "dockedItems"], function(key){
        if (o[key]) {
          var items = [].concat(o[key]); // we need to do it in order to esure that this instance has a separate bbar/tbar/etc, NOT shared via class' prototype
          delete(o[key]);
          o[key] = items;
          this.detectActions(o[key]);
        }
      }, this);
    } else if (Ext.isArray(o)) {
      var a = o;
      Ext.each(a, function(el, i){
        if (Ext.isObject(el)) {
          if (el.symbol) {
            if (!this.actions[el.symbol.camelize(true)]) throw "Netzke: action '"+el.symbol+"' not defined";
            a[i] = this.actions[el.symbol.camelize(true)];
            delete(el);
          } else {
            this.detectActions(el);
          }
        }
      }, this);
    }
  },

  /*
  Dynamically loads a Netzke component.
  Config options:
  'name' (required) - the name of the child component to load
  'container' - if specified, the id (or instance) of a panel with the 'fit' layout where the loaded component will be added to; the previously existing component will be destroyed
  'callback' - function that gets called after the component is loaded; it receives the component's instance as parameter
  'scope' - scope for the callback
  */
  loadNetzkeComponent: function(params){
    if (params.id) {
      params.name = params.id;
      Netzke.deprecationWarning("Using 'id' in loadComponent is deprecated. Use 'name' instead.");
    }

    params.name = params.name.underscore();

    // params that will be provided for the server API call (deliver_component); all what's passed in params.params is merged in. This way we exclude from sending along such things as :scope, :callback, etc.
    var serverParams = params.params || {};
    serverParams.name = params.name;

    // coma-separated list of xtypes of already loaded classes
    serverParams.cache = Netzke.cache.join();

    var storedConfig = this.componentsBeingLoaded[params.name] = params;

    // Remember where the loaded component should be inserted into
    var containerCmp = params.container && Ext.isString(params.container) ? Ext.getCmp(params.container) : params.container;
    storedConfig.container = containerCmp;

    // Show loading mask if possible
    var containerEl = (containerCmp || this).getEl();
    if (this.componentLoadMask && containerEl){
      storedConfig.loadMaskCmp = new Ext.LoadMask(containerEl, this.componentLoadMask);
      storedConfig.loadMaskCmp.show();
    }

    // do the remote API call
    this.deliverComponent(serverParams);
  },

  // DEPRECATED in favor or loadNetzkeComponent
  loadComponent: function(params) {
    Netzke.deprecationWarning("loadComponent is deprecated in favor of loadNetzkeComponent");
    params.container = params.container || this.getId(); // for backward compatibility
    this.loadNetzkeComponent(params);
  },

  /*
  Called by the server after we ask him to load a component
  */
  componentDelivered: function(config){
    // retrieve the loading config for this component
    var storedConfig = this.componentsBeingLoaded[config.name] || {};
    delete this.componentsBeingLoaded[config.name];

    if (storedConfig.loadMaskCmp) {
      storedConfig.loadMaskCmp.hide();
      storedConfig.loadMaskCmp.destroy();
    }

    var componentInstance = Ext.createByAlias(config.alias, config);

    if (storedConfig.container) {
      var containerCmp = storedConfig.container;
      if (!storedConfig.append) containerCmp.removeAll();
      containerCmp.add(componentInstance);

      if (containerCmp.isVisible()) {
        containerCmp.doLayout();
      } else {
        // if loaded into a hidden container, we need a little trick
        containerCmp.on('show', function(cmp){ cmp.doLayout(); }, {single: true});
      }
    }

    if (storedConfig.callback) {
      storedConfig.callback.call(storedConfig.scope || this, componentInstance);
    }

    this.fireEvent('componentload', componentInstance);
  },

  componentDeliveryFailed: function(params) {
    var storedConfig = this.componentsBeingLoaded[params.componentName] || {};
    delete this.componentsBeingLoaded[params.componentName];

    if (storedConfig.loadMaskCmp) {
      storedConfig.loadMaskCmp.hide();
      storedConfig.loadMaskCmp.destroy();
    }

    this.netzkeFeedback({msg: params.msg, level: "Error"});
  },

  /*
  DEPRECATED. Instantiates and renders a component with given config and container.
  */
  instantiateAndRenderComponent: function(config, containerId){
    var componentInstance;
    if (containerId) {
      var container = Ext.getCmp(containerId);
      componentInstance = container.instantiateChild(config);
    } else {
      componentInstance = this.instantiateChild(config);
    }
    return componentInstance;
  },

  /*
  Returns parent Netzke component
  */
  getParentNetzkeComponent: function(){
    // simply cutting the last part of the id: some_parent__a_kid__a_great_kid => some_parent__a_kid
    var idSplit = this.id.split("__");
    idSplit.pop();
    var parentId = idSplit.join("__");

    return parentId === "" ? null : Ext.getCmp(parentId);
  },

  // DEPRECATED
  getParent: function() {
    Netzke.deprecationWarning("getParent is deprecated in favor of getParentNetzkeComponent");
    return this.getParentNetzkeComponent();
  },

  /*
  Reloads current component (calls the parent to reload us as its component)
  */
  reload: function(){
    var parent = this.getParentNetzkeComponent();
    if (parent) {
      parent.loadNetzkeComponent({id:this.localId(parent), container:this.ownerCt.id});
    } else {
      window.location.reload();
    }
  },

  /*
  DEPRECATED: Reconfigures the component
  */
  reconfigure: function(config){
    this.ownerCt.instantiateChild(config)
  },

  /*
  Instantiates and returns a Netzke component by its name.
  */
  instantiateChildNetzkeComponent: function(name) {
    name = name.camelize(true);
    return Ext.createByAlias(this.netzkeComponents[name].alias, this.netzkeComponents[name])
  },

  /*
  Returns *instantiated* child component by its relative id, which may contain the 'parent' part to walk _up_ the hierarchy
  */
  getChildNetzkeComponent: function(id){
    if (id === "") {return this};
    id = id.underscore();
    var split = id.split("__");
    if (split[0] === 'parent') {
      split.shift();
      var childInParentScope = split.join("__");
      return this.getParentNetzkeComponent().getChildNetzkeComponent(childInParentScope);
    } else {
      return Ext.getCmp(this.id+"__"+id);
    }
  },

  // DEPRECATED
  getChildComponent: function(id) {
    Netzke.deprecationWarning("getChildComponent is deprecated in favor of getChildNetzkeComponent");
    return this.getChildNetzkeComponent(id);
  },

  /*
  Provides a visual feedback. TODO: refactor
  */
  netzkeFeedback: function(msg){
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

  // DEPRECATED in favor of netzkeFeedback
  feedback: function(msg) {
    Netzke.deprecationWarning("feedback is deprecated in favor of netzkeFeedback");
    this.netzkeFeedback(msg);
  },

  /*
  Common handler for all netzke's actions. <tt>comp</tt> is the Component that triggered the action (e.g. button or menu item)
  */
  actionHandler: function(comp){
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
  toolActionHandler: function(tool){
    // If firing corresponding event doesn't return false, call the handler
    if (this.fireEvent(tool.id+'click')) {
      var methodName = "on"+tool.camelize();
      if (!this[methodName]) {throw "Netzke: handler for tool '"+tool+"' is undefined"}
      this[methodName]();
    }
  },

  processPlugins: function() {
    if (this.netzkePlugins) {
      if (!this.plugins) this.plugins = [];
      Ext.each(this.netzkePlugins, function(p){
        this.plugins.push(this.instantiateChildNetzkeComponent(p));
      }, this);
    }
  },

  onComponentLoad:Ext.emptyFn // gets overridden
});
