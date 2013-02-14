// This file has stuff related to Ext JS (as apposed to Touch)

// Because of Netzke's double-underscore notation, Ext.TabPanel should have a different id-delimiter (yes, this should be in netzke-core)
Ext.TabPanel.prototype.idDelimiter = "___";

// Enable quick tips
Ext.QuickTips.init();

// Checking Ext JS version: both major and minor versions must be the same
(function(){
  var requiredVersionMajor = 4,
      requiredVersionMinor = 1,
      extVersion = Ext.getVersion('extjs'),
      currentVersionMajor = extVersion.getMajor(),
      currentVersionMinor = extVersion.getMinor(),
      requiredString = "" + requiredVersionMajor + "." + requiredVersionMinor + ".x";

  if (requiredVersionMajor != currentVersionMajor || requiredVersionMinor != currentVersionMinor) {
    Netzke.warning("Ext JS " + requiredString + " required (you have " + extVersion.toString() + ").");
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

// Override Ext.Component's constructor to enable Netzke features
Ext.define(null, {
  override: 'Ext.Component',
  constructor: function(config) {
    if (this.isNetzke) {

      this.netzkeComponents = config.netzkeComponents;
      this.passedConfig = config;

      // process and get rid of endpoints config
      this.netzkeProcessEndpoints(config);

      // process and get rid of plugins config
      this.netzkeProcessPlugins(config);

      this.netzkeNormalizeActions(config);

      this.netzkeNormalizeConfig(config);

      this.netzkeNormalizeTools(config);

      // This is where the references to different callback functions will be stored
      this.callbackHash = {};

      // This is where we store the information about components that are currently being loaded with this.loadComponent()
      this.componentsBeingLoaded = {};
    }

    this.callOverridden([config]);
  }
});

Netzke.directProvider = new Netzke.classes.NetzkeRemotingProvider({
  type: "remoting",       // create a Ext.direct.RemotingProvider
  url: Netzke.ControllerUrl + "direct/", // url to connect to the Ext.Direct server-side router.
  namespace: "Netzke.providers", // namespace to create the Remoting Provider in
  actions: {},
  maxRetries: Netzke.core.directMaxRetries,
  enableBuffer: true, // buffer/batch requests within 10ms timeframe
  timeout: 30000 // 30s timeout per request
});

Ext.Direct.addProvider(Netzke.directProvider);

// Methods/properties that each and every Netzke component will have
Ext.define(null, {
  override: 'Netzke.classes.Core.Mixin',
  feedbackGhost: Ext.create("Netzke.FeedbackGhost"),

  /*
  Mask shown during loading of a component. Set to false to not mask. Pass config for Ext.LoadMask for configuring msg/cls, etc.
  Set msg to null if mask without any msg is desirable.
  */
  netzkeLoadMask: true,

  /**
   * Runs through initial config options and does the following:
   *
   * * detects component placeholders and replaces them with full component config found in netzkeComponents
   * * detects action placeholders and replaces them with instances of Ext actions found in this.actions
   * @private
   */
  netzkeNormalizeConfig: function(config) {
    for (key in config) {
      if (Ext.isArray(config[key])) this.netzkeNormalizeConfigArray(config[key]);
    }
  },

  /**
  * Dynamically creates methods for endpoints, so that we could later call them like: this.myEndpointMethod()
  * @private
  */
  netzkeProcessEndpoints: function(config){
    var endpoints = config.endpoints || [];
    endpoints.push('deliver_component'); // all Netzke components get this endpoint
    var directActions = [];
    var that = this;

    Ext.each(endpoints, function(intp){
      directActions.push({"name":intp.camelize(true), "len":1});
      this[intp.camelize(true)] = function(arg, callback, scope) {
        Netzke.runningRequests++;

        scope = scope || that;
        Netzke.providers[config.id][intp.camelize(true)].call(scope, arg, function(result, remotingEvent) {
          if(remotingEvent.message) {
            console.error("RPC event indicates an error: ", remotingEvent);
            throw new Error(remotingEvent.message);
          }
          that.netzkeBulkExecute(result); // invoke the endpoint result on the calling component
          if(typeof callback == "function") {
            callback.call(scope, that.latestResult); // invoke the callback on the provided scope, or on the calling component if no scope set. Pass latestResult to callback
          }
          Netzke.runningRequests--;
        });
      }
    }, this);

    Netzke.directProvider.addAction(config.id, directActions);

    delete config.endpoints;
  },

  /**
   * @private
   */
  netzkeNormalizeTools: function(config) {
    if (config.tools) {
      var normTools = [];
      Ext.each(config.tools, function(tool){
        // Create an event for each action (so that higher-level components could interfere)
        this.addEvents(tool.id+'click');

        var handler = Ext.Function.bind(this.netzkeToolHandler, this, [tool]);
        normTools.push({type : tool, handler : handler, scope : this});
      }, this);
      this.tools = normTools;
      delete config.tools;
    }
  },

  /**
    * Replaces actions configs with Ext.Action instances, assigning default handler to them
    * @private
    */
  netzkeNormalizeActions : function(config){
    var normActions = {};
    for (var name in config.actions) {
      // Create an event for each action (so that higher-level components could interfere)
      this.addEvents(name+'click');

      // Configure the action
      var actionConfig = Ext.apply({}, config.actions[name]); // do not modify original this.actions
      actionConfig.customHandler = actionConfig.handler;
      actionConfig.handler = Ext.Function.bind(this.netzkeActionHandler, this); // handler common for all actions
      actionConfig.name = name;
      normActions[name] = new Ext.Action(actionConfig);
    }
    this.actions = normActions;
    delete(config.actions);
  },

  /**
   * Dynamically loads a Netzke component.
   * @param {String} name
   * @param {Object} config Can contain the following keys:
   *   'container' - if specified, the instance (or id) of a panel with the 'fit' layout where the loaded component will be added to; the previously existing component will be destroyed
   *   'append' - if set to +true+, do not clear the container before adding the loaded component
   *   'callback' - function that gets called after the component is loaded; it receives the component's instance as parameter
   *   'configOnly' - if set to +true+, do not instantiate the component, instead pass its config to the callback function
   *   'params' - object passed to the endpoint, may be useful for extra configuration
   *   'scope' - scope for the callback
   *
   * Examples:
   *
   *    this.netzkeLoadComponent('info');
   *
   * loads 'info' and adds it to +this+ container, removing anything from it first.
   *
   *    this.netzkeLoadComponent('info', {container: win, callback: function(instance){}, scope: this});
   *
   * loads 'info' and adds it to +win+ container, envoking a callback in +this+ scope, passing it an instance of 'info'.
   *
   *    this.netzkeLoadComponent('info', {configOnly: true, callback: function(config){}, scope: this});
   *
   * loads configuration for the 'info' component, envoking a callback in +this+ scope, passing it the loaded config for 'info'.
   */
  netzkeLoadComponent: function(){
    var params;

    if (Ext.isString(arguments[0])) {
      params = arguments[1] || {};
      params.name = arguments[0];
    } else {
      params = arguments[0];
    }

    if (params.container == undefined) params.container = this;
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
    if (this.netzkeLoadMask && containerEl){
      storedConfig.loadMaskCmp = new Ext.LoadMask(containerEl, this.netzkeLoadMask);
      storedConfig.loadMaskCmp.show();
    }

    // do the remote API call
    this.deliverComponent(serverParams);
  },

  /**
   * Called by the server after we ask him to load a component
   * @private
  */
  netzkeComponentDelivered: function(config){
    // retrieve the loading config for this component
    var storedConfig = this.componentsBeingLoaded[config.name] || {};
    var callbackParam;
    delete this.componentsBeingLoaded[config.name];

    if (storedConfig.loadMaskCmp) {
      storedConfig.loadMaskCmp.hide();
      storedConfig.loadMaskCmp.destroy();
    }

    if (storedConfig.configOnly) {
      callbackParam = config;
    } else {
      var componentInstance = Ext.ComponentManager.create(config);

      // there's no sense in adding a window-type components
      if (storedConfig.container && !componentInstance.isFloating()) {
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
      callbackParam = componentInstance;
    }

    if (storedConfig.callback) {
      storedConfig.callback.call(storedConfig.scope || this, callbackParam);
    }
  },

  /**
   * @private
   */
  netzkeComponentDeliveryFailed: function(params) {
    var storedConfig = this.componentsBeingLoaded[params.componentName] || {};
    delete this.componentsBeingLoaded[params.componentName];

    if (storedConfig.loadMaskCmp) {
      storedConfig.loadMaskCmp.hide();
      storedConfig.loadMaskCmp.destroy();
    }

    this.netzkeFeedback({msg: params.msg, level: "Error"});
  },

  /**
  * Returns parent Netzke component
  */
  netzkeGetParentComponent: function(){
    // simply cutting the last part of the id: some_parent__a_kid__a_great_kid => some_parent__a_kid
    var idSplit = this.id.split("__");
    idSplit.pop();
    var parentId = idSplit.join("__");

    return parentId === "" ? null : Ext.getCmp(parentId);
  },

  /**
   * Reloads itself by instructing the parent to call `netzkeLoadComponent`.
   * Note: in order for this to work, the component must be nested in a container with the 'fit' layout.
  */
  netzkeReload: function(){
    var parent = this.netzkeGetParentComponent();

    if (parent) {
      var name = this.netzkeLocalId(parent);
      parent.netzkeLoadComponent(name, {container:this.ownerCt.id});
    } else {
      window.location.reload();
    }
  },

  /**
  * Instantiates and returns a Netzke component by its name.
  * @private
  */
  netzkeInstantiateComponent: function(name) {
    name = name.camelize(true);
    return Ext.createByAlias(this.netzkeComponents[name].alias, this.netzkeComponents[name])
  },

  /**
  * Returns *instantiated* child component by its relative id, which may contain the 'parent' part to walk _up_ the hierarchy
  * @private
  */
  netzkeGetComponent: function(id){
    if (id === "") {return this};
    id = id.underscore();
    var split = id.split("__");
    if (split[0] === 'parent') {
      split.shift();
      var childInParentScope = split.join("__");
      return this.netzkeGetParentComponent().netzkeGetComponent(childInParentScope);
    } else {
      return Ext.getCmp(this.id+"__"+id);
    }
  },

  /**
  * Provides a visual feedback. TODO: refactor
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

  /**
  * Common handler for all netzke's actions. <tt>comp</tt> is the Component that triggered the action (e.g. button or menu item)
  * @private
  */
  netzkeActionHandler: function(comp){
    var actionName = comp.name;
    // If firing corresponding event doesn't return false, call the handler
    if (this.fireEvent(actionName+'click', comp)) {
      var action = this.actions[actionName];
      var customHandler = action.initialConfig.customHandler;
      var methodName = (customHandler && customHandler.camelize(true)) || "on" + actionName.camelize();
      if (!this[methodName]) {throw "Netzke: handler '" + methodName + "' is undefined in '" + this.id + "'";}

      // call the handler passing it the triggering component
      this[methodName](comp);
    }
  },

  /**
   * Common handler for tools
   * @private
   */
  netzkeToolHandler: function(tool){
    // If firing corresponding event doesn't return false, call the handler
    if (this.fireEvent(tool.id+'click')) {
      var methodName = "on"+tool.camelize();
      if (!this[methodName]) {throw "Netzke: handler for tool '"+tool+"' is undefined"}
      this[methodName]();
    }
  },

  /**
   * @private
   */
  netzkeProcessPlugins: function(config) {
    if (config.netzkePlugins) {
      if (!this.plugins) this.plugins = [];
      Ext.each(config.netzkePlugins, function(p){
        this.plugins.push(this.netzkeInstantiateComponent(p));
      }, this);
      delete config.netzkePlugins;
    }
  },

  // netzkeOnComponentLoad: Ext.emptyFn // gets overridden
});
