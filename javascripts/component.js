// Override Ext.Component's constructor to enable Netzke features
Ext.define(null, {
  override: 'Ext.Component',
  constructor: function(config) {
    if (this.isNetzke) this.netzkeInitialize(config);
    this.callParent([config]);
  }
});

Ext.define("Netzke.classes.Core.Mixin", {
  isNetzke: true, // to distinguish Netzke components from regular Ext components

  netzkeInitialize: function(config){
    // component loading index
    this.netzkeLoadingIndex = 0;

    this.netzkeComponents = config.netzkeComponents;

    // TODO: needed?
    this.passedConfig = config;

    // process and get rid of endpoints config
    this.netzkeProcessEndpoints(config);

    // process and get rid of plugins config
    this.netzkeProcessPlugins(config);

    this.netzkeNormalizeActions(config);

    this.netzkeNormalizeConfig(config);

    // This is where the references to different callback functions will be stored
    this.callbackHash = {};

    // This is where we store the information about components that are currently being loaded with this.loadComponent()
    this.componentsBeingLoaded = {};

    this.netzkeClientConfig = config.clientConfig || {};
  },

  feedbackGhost: Ext.create("Netzke.FeedbackGhost"),

  /**
  * Evaluates CSS
  * @private
  */
  netzkeEvalCss : function(code){
    var head = Ext.fly(document.getElementsByTagName('head')[0]);
    Ext.core.DomHelper.append(head, {
      tag: 'style',
      type: 'text/css',
      html: code
    });
  },

  /**
  * Evaluates JS
  * @private
  */
  netzkeEvalJs : function(code){
    eval(code);
  },

  /**
  * Gets id in the context of provided parent.
  * For example, the components "properties", being a child of "books" has global id "books__properties", which *is* its component's real id. This methods, with the instance of "books" passed as parameter, returns "properties".
  * @private
  */
  netzkeLocalId : function(parent){
    return this.id.replace(parent.id + "__", "");
  },

  /**
  Executes a bunch of methods. This method is called almost every time a communication to the server takes place.
  Thus the server side of a component can provide any set of commands to its client side.
  Args:
    - instructions: can be
      1) a hash of instructions, where the key is the method name, and value - the argument that method will be called with (thus, these methods are expected to *only* receive 1 argument). In this case, the methods will be executed in no particular order.
      2) an array of hashes of instructions. They will be executed in order.
      Arrays and hashes may be nested at will.
      If the key in the instructions hash refers to a child Netzke component, netzkeBulkExecute will be called on that component with the value passed as the argument.

  Examples of the arguments:
      // same as this.feedback("Your order is accepted");
      {feedback: "You order is accepted"}

      // same as: this.setTitle('Suprise!'); this.setDisabled(true);
      [{setTitle:'Suprise!'}, {setDisabled:true}]

      // the same as this.netzkeGetComponent('users').netzkeBulkExecute([{setTitle:'Suprise!'}, {setDisabled:true}]);
      {users: [{setTitle:'Suprise!'}, {setDisabled:true}] }
  @private
  */
  netzkeBulkExecute : function(instructions){
    if (Ext.isArray(instructions)) {
      Ext.each(instructions, function(instruction){ this.netzkeBulkExecute(instruction)}, this);
    } else {
      for (var instr in instructions) {
        var args = instructions[instr];
        if(args instanceof Object && (Ext.Object.getSize(args)==0))
          args = [];

        if (Ext.isFunction(this[instr])) {
          // Executing the method.
          this[instr].apply(this, args);
        } else {
          var childComponent = this.netzkeGetComponent(instr);
          if (childComponent) {
            childComponent.netzkeBulkExecute(args);
          } else if (Ext.isArray(args)) { // only consider those calls that have arguments wrapped in an array; the only (probably) case when they are not, is with 'success' property set to true in a non-ajax form submit - silently ignore that
            throw "Netzke: Unknown method or child component '" + instr + "' in component '" + this.id + "'"
          }
        }
      }
    }
  },

  /**
   * @private
   */
  netzkeSetResult: function(result) {
    this.latestResult = result;
  },

  /**
  * This method gets called by the server when the component to which an endpoint call was directed to, is not in the session anymore.
  * @private
  */
  netzkeSessionExpired: function() {
    this.netzkeSessionIsExpired = true;
    this.onNetzkeSessionExpired();
  },

  /**
   * Override this method to handle session expiration. E.g. you may want to inform the user that they will be redirected to the login page.
   * @private
   */
  onNetzkeSessionExpired: function() {
    Netzke.warning("Component not in session. Override `onNetzkeSessionExpired` to handle this.");
  },

  /**
   * Returns a URL for old-fashion requests (used at multi-part form non-AJAX submissions)
   * @private
   */
  netzkeEndpointUrl: function(endpoint){
    return Netzke.ControllerUrl + "dispatcher?address=" + this.id + "__" + endpoint;
  },

  /**
   * @private
   */
  netzkeNormalizeConfigArray: function(items){
    var cfg, ref, cmpName, cmpCfg, actName, actCfg;

    Ext.each(items, function(item, i){
      cfg = item;

      // potentially, referencing a component or action with a string
      if (Ext.isString(item)) {
        ref = item.camelize(true);
        if ((this.netzkeComponents || {})[ref]) cfg = {netzkeComponent: ref};
        else if ((this.actions || {})[ref]) cfg = {netzkeAction: ref};
      }

      if (cfg.netzkeAction) {
        // replace with action instance
        actName = cfg.netzkeAction.camelize(true);
        if (!this.actions[actName]) throw "Netzke: unknown action " + cfg.netzkeAction;
        items[i] = this.actions[actName];
        delete(item);

      } else if (cfg.netzkeComponent) {
        // replace with component config
        cmpName = cfg.netzkeComponent;
        cmpCfg = this.netzkeComponents[cmpName.camelize(true)];
        if (!cmpCfg) throw "Netzke: unknown component " + cmpName;
        cmpCfg.netzkeParent = this;
        items[i] = Ext.apply(cmpCfg, cfg);
        delete(item);

      } else if (Ext.isString(cfg) && Ext.isFunction(this[cfg.camelize(true)+"Config"])) { // replace with config referred to on the Ruby side as a symbol
        // pre-built config
        items[i] = Ext.apply(this[cfg.camelize(true)+"Config"](this.passedConfig), {netzkeParent: this});

      } else {
        // recursion
        for (key in cfg) {
          if (Ext.isArray(cfg[key])) {
            this.netzkeNormalizeConfigArray(cfg[key]);
          }
        }
      }
    }, this);
  },

  netzkeInitializeDirectProvider: function(actions){
    this.nzDirect = {}; // namespace for direct functions

    Ext.direct.Manager.addProvider({
      netzkeOwner: this,
      type: 'netzkeremoting',
      namespace: this.nzDirect,
      actions: actions
    });
  },

  /*
  Mask shown during loading of a component. Set to false to not mask. Pass config for Ext.LoadMask for configuring msg/cls, etc.
  Set msg to null if mask without any msg is desirable.
  */
  netzkeLoadMask: false, // TODO: reenable

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

    var epActions = [], actions = {}, that = this;
    actions[config.path] = epActions;

    Ext.each(endpoints, function(ep){
      var methodName = ep.camelize(true);
      epActions.push({name: methodName, len: 1});

      this[methodName] = function(){
        var args = Array.prototype.slice.call(arguments), callback, serverConfigs, scope = that;

        if (Ext.isFunction(args[args.length - 2])) {
          scope = args.pop();
          callback = args.pop();
        }

        if (Ext.isFunction(args[args.length - 1])) {
          callback = args.pop();
        }

        this.netzkeGetDirectFunction(methodName, config).call(this, args, function(result, event){
          var callbackParam = event;

          if (Ext.getClass(event) == Ext.direct.RemotingEvent) { // means we didn't get an exception
            that.netzkeBulkExecute(result); // invoke the endpoint result on the calling component
            callbackParam = that.latestResult;
          }

          if (callback && !that.netzkeSessionIsExpired) {
            // Invoke the callback on the provided scope, or on the calling component if no scope set.
            // Pass latestResult to callback in case of success, or the Ext.direct.ExceptionEvent otherwise.
            callback.call(scope, callbackParam);
          }
        });
      }
    }, this);

    this.netzkeInitializeDirectProvider(actions);
  },

  netzkeGetDirectFunction: function(methodName, config) {
    config = config || this;
    return this.nzDirect[config.path][methodName];
  },

  /**
   * Array of client configs for each parent down the tree
   * @private
   */
  buildParentClientConfigs: function() {
    this._parentClientConfig = [];
    var parent = this;
    while (parent) {
      var cfg = Ext.clone(parent.netzkeClientConfig);
      cfg.component_id = parent.id;
      this._parentClientConfig.unshift(cfg);
      parent = parent.netzkeGetParentComponent();
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
    * Replaces actions configs with Ext.Action instances, assigning default handler to them
    * @private
    */
  netzkeNormalizeActions : function(config){
    var normActions = {};
    for (var name in config.actions) {
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
    });
  },

  /**
   * Called by the server after we ask him to load a component
   * @private
  */
  netzkeComponentDelivered: function(config){
    var storedConfig = this.netzkeUndoLoadingComponent(config.itemId),
        callbackParam = Ext.apply(config, storedConfig);

    config.netzkeParent = this;

    if (!storedConfig.configOnly) {
      var currentCmp = Ext.ComponentManager.get(config.id);
      if (currentCmp) currentCmp.destroy();

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
      storedConfig.callback.call(storedConfig.scope || this, callbackParam, storedConfig);
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
    return this.netzkeParent;
  },

  /**
   * Reloads itself by instructing the parent to call `netzkeLoadComponent`.
   * Note: in order for this to work, the component must be nested in a container with the 'fit' layout.
  */
  netzkeReload: function(){
    var parent = this.netzkeGetParentComponent();

    if (parent) {
      parent.netzkeReloadChild(this);
    } else {
      window.location.reload();
    }
  },

  /**
   * WIP
   */
  netzkeReloadChild: function(child, clientConfig){
    clientConfig = clientConfig || {};
    this.netzkeLoadComponent(child.name, {
      configOnly: true,
      callback: function(cfg) {
        this.netzkeReplaceChild(child, cfg);
      }
    });
  },

  /**
   * WIP
   */
  netzkeReplaceChild: function(child, config){
    var index = this.items.indexOf(child);
    this.remove(child);
    this.insert(index, config);
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
    var split = id.split("__"), res;
    if (split[0] === 'parent') {
      split.shift();
      var childInParentScope = split.join("__");
      res = this.netzkeGetParentComponent().netzkeGetComponent(childInParentScope);
    } else {
      res = Ext.getCmp(this.id+"__"+id);
    }
    return res;
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
