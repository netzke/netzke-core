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
  showFeedback: function(msg, options){
    options = options || {};
    options.delay = options.delay || Netzke.core.FeedbackDelay;
    if (Ext.isObject(msg)) {
      this.msg(msg.level.camelize(), msg.msg, options.delay);
    } else if (Ext.isArray(msg)) {
      Ext.each(msg, function(m) { this.showFeedback(m); }, this);
    } else {
      this.msg(null, msg, options.delay); // no header for now
    }
  },

  msg: function(title, format, delay){
      if(!this.msgCt){
          this.msgCt = Ext.core.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
      }
      var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
      var m = Ext.core.DomHelper.append(this.msgCt, this.createBox(title, s), true);
      m.hide();
      m.slideIn('t').ghost("t", { delay: delay, remove: true});
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

  initComponent: function() {
    this.callParent();
    this.addEvent('serverexception'); // because 'exception' is reserved by Ext JS (but never used!)
  },

  listeners: {
    // work-around the fact that 'exception' is never thrown by Ext JS
    data: function(self, e) {
      if (Ext.getClass(e) == Ext.direct.ExceptionEvent) {
        this.fireEvent('serverexception', e);
      }
    }
  },

  getCallData: function(t){
    return {
      path: t.action,
      endpoint: t.method,
      data: t.data,
      tid: t.id
    }
  },

  addEndpointsForComponent: function(componentPath, endpoints) {
    var cls = this.namespace[componentPath] || (this.namespace[componentPath] = {});

    Ext.Array.each(endpoints, function(ep) {
      var methodName = ep.camelize(true),
          method = Ext.create('Ext.direct.RemotingMethod', {name: methodName, len: 1, blah: 666});
      cls[methodName] = this.createHandler(componentPath, method);
    }, this);
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
  url: Netzke.ControllerUrl + "direct/", // url to connect to the Ext.Direct server-side router.
  namespace: "Netzke.providers", // Netzke.providers will have a key per Netzke component, each mapped to a hash with a RemotingMethod per endpoint
  actions: {},
  maxRetries: Netzke.core.directMaxRetries,
  enableBuffer: true, // buffer/batch requests within 10ms timeframe
  timeout: 30000 // 30s timeout per request
});

Ext.Direct.addProvider(Netzke.directProvider);

// Override Ext.Component's constructor to enable Netzke features
Ext.define(null, {
  override: 'Ext.Component',
  constructor: function(config) {
    if (this.isNetzke) {
      // component loading index
      this.netzkeLoadingIndex = 0;

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

    Netzke.directProvider.addEndpointsForComponent(config.path, endpoints);

    var that = this;

    Ext.each(endpoints, function(ep){
      var methodName = ep.camelize(true);

      /* add endpoint method to `this` */
      this[methodName] = function(args, callback, scope) {
        Netzke.runningRequests++;

        scope = scope || that;

        var cfgs = this.buildParentClientConfigs();
        var remotingArgs = {args: args, configs: cfgs};

        Netzke.providers[config.path][methodName].call(scope, remotingArgs, function(result, e) {
          var callbackParam = e;

          if (Ext.getClass(e) == Ext.direct.RemotingEvent) { // means we didn't get an exception
            that.netzkeBulkExecute(result); // invoke the endpoint result on the calling component
            callbackParam = that.latestResult;
          }

          if (typeof callback == "function" && !scope.netzkeSessionIsExpired) {
            callback.call(scope, callbackParam); // invoke the callback on the provided scope, or on the calling component if no scope set. Pass latestResult to callback in case of success, or the Ext.direct.ExceptionEvent otherwise
          }

          Netzke.runningRequests--;
        });
      }
    }, this);

    delete config.endpoints;
  },

  /**
   * Array of client configs for each parent down the tree
   * @private
   */
  buildParentClientConfigs: function() {
    if (!this._parentClientConfig) {
      this._parentClientConfig = [];
      var parent = this;
      while (parent) {
        var cfg = parent.clientConfig || {};
        cfg.id = parent.id;
        this._parentClientConfig.unshift(cfg);
        parent = parent.netzkeGetParentComponent();
      }
    }

    return this._parentClientConfig;
  },

  /**
   * @private
   * Handles endpoint exceptions. Ext.direct.ExceptionEvent gets passed as parameter. Override to handle server side exceptions.
   */
  onDirectException: function(e) {
    Netzke.warning("Server error. Override onDirectException to handle this.");
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
   *   'clone' - if set to +true+, allows loading multiple instances of the same child component
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

    // support 2 different signatures
    if (Ext.isString(arguments[0])) {
      params = arguments[1] || {};
      params.name = arguments[0];
    } else {
      params = arguments[0];
    }

    if (params.container == undefined) params.container = this;
    params.name = params.name.underscore();

    /* params that will be provided for the server API call (deliver_component); all what's passed in params.params is
    * merged in. This way we exclude from sending along such things as :scope and :callback */
    var serverParams = params.params || {};
    serverParams["name"] = params.name;
    serverParams["client_config"] = params.clientConfig;

    // by which the loaded component will be referred in +netzkeComponentDelivered+
    var itemId = params.name;

    // multi-instance loading
    if (params.clone) {
      serverParams["index"] = this.netzkeLoadingIndex;
      itemId += this.netzkeLoadingIndex; // << index
      this.netzkeLoadingIndex++;
    }

    // coma-separated list of xtypes of already loaded classes
    serverParams["cache"] = Netzke.cache.join();

    var storedConfig = this.componentsBeingLoaded[itemId] = params;

    // Remember where the loaded component should be inserted into
    var containerCmp = params.container && Ext.isString(params.container) ? Ext.getCmp(params.container) : params.container;
    storedConfig.container = containerCmp;

    // Show loading mask if possible
    var containerEl = (containerCmp || this).getEl();
    if (this.netzkeLoadMask && containerEl){
      storedConfig.loadMaskCmp = new Ext.LoadMask(containerEl, this.netzkeLoadMask);
      storedConfig.loadMaskCmp.show();
    }

    // Call the endpoint
    this.deliverComponent(serverParams, function(e) {
      if (Ext.getClass(e) == Ext.direct.ExceptionEvent) {
        this.netzkeUndoLoadingComponent(params.name);
      }
    }, this);
  },

  /**
   * Called by the server after we ask him to load a component
   * @private
  */
  netzkeComponentDelivered: function(config){
    var storedConfig = this.netzkeUndoLoadingComponent(config.itemId),
        callbackParam;

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
   * Destroys the loading mask and removes the component from componentsBeingLoaded
   * @private
   */
  netzkeUndoLoadingComponent: function(itemId) {
    var storedConfig = this.componentsBeingLoaded[itemId] || {};
    delete this.componentsBeingLoaded[itemId];

    if (storedConfig.loadMaskCmp) {
      storedConfig.loadMaskCmp.hide();
      storedConfig.loadMaskCmp.destroy();
    }

    return storedConfig;
  },

  /**
   * @private
   */
  netzkeComponentDeliveryFailed: function(params) {
    var storedConfig = this.componentsBeingLoaded[params.itemId] || {};
    delete this.componentsBeingLoaded[params.itemId];

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
    var cfg = this.netzkeComponents[name];
    return Ext.createByAlias(this.netzkeComponents[name].alias, cfg)
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
  * msg can be a string, an array of strings, an object in form {msg: 'Message'}, or an array of such objects.
  */
  netzkeFeedback: function(msg, options){
    if (this.initialConfig && this.initialConfig.quiet) return false;

    options = options || {};

    if (typeof msg == 'string'){ msg = [msg]; }

    var feedback = "";

    Ext.each(msg, function(m){
      feedback += (m.msg || m) + "<br/>"
    });

    if (feedback != "") {
      this.feedbackGhost.showFeedback(feedback, {delay: options.delay});
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
  }
});
