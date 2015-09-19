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

  // Component that used for notifications (to be reworked)
  feedbackGhost: Ext.create("Netzke.FeedbackGhost"),

  netzkeInitialize: function(config){
    this.netzkeComponents = config.netzkeComponents;
    this.passedConfig = config;
    this.netzkeProcessEndpoints(config);
    this.netzkeProcessPlugins(config);
    this.netzkeNormalizeActions(config);
    this.netzkeNormalizeConfig(config);
    this.serverConfig = config.clientConfig || {};
  },

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
  Executes a bunch of methods. This method is called almost every time a communication to the server takes place.
  Thus the server side of a component can provide any set of commands to its client side.
  Args:
    - instructions: can be
      1) a hash of instructions, where the key is the method name, and value - the argument that method will be called with (thus, these methods are expected to *only* receive 1 argument). In this case, the methods will be executed in no particular order.
      2) an array of hashes of instructions. They will be executed in order.
      Arrays and hashes may be nested at will.
      If the key in the instructions hash refers to a child Netzke component, netzkeBulkExecute will be called on that component with the value passed as the argument.

  Examples of the arguments:
      // executes as this.feedback("Your order is accepted");
      {feedback: "You order is accepted"}

      // executes as: this.setTitle('Suprise!'); this.setDisabled(true);
      [{setTitle:'Suprise!'}, {setDisabled:true}]

      // executes as: this.netzkeGetComponent('users').netzkeBulkExecute([{setTitle:'Suprise!'}, {setDisabled:true}]);
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
            throw "Netzke: Unknown method or child component '" + instr + "' in component '" + this.path + "'"
          }
        }
      }
    }
  },

  /**
   * Called by the server side to set the return value of an endpoint call; to be reworked.
   * @protected
   */
  netzkeSetResult: function(result) {
    this.latestResult = result;
  },

  /**
  * Called by the server when the component to which an endpoint call was directed to, is not in the session anymore.
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
   * Processes items
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
    var endpoints = config.endpoints || [], that = this;

    Ext.each(endpoints, function(methodName){
      Netzke.directProvider.addRemotingMethodToComponent(config, methodName);

      // define endpoint function
      this[methodName] = function(){
        var args = Array.prototype.slice.call(arguments), callback, serverConfigs, scope = that;

        if (Ext.isFunction(args[args.length - 2])) {
          scope = args.pop();
          callback = args.pop();
        }

        if (Ext.isFunction(args[args.length - 1])) {
          callback = args.pop();
        }

        var cfgs = this.netzkeBuildParentConfigs();
        var remotingArgs = {args: args, configs: cfgs};

        // call Direct function
        this.netzkeGetDirectFunction(methodName).call(scope, remotingArgs, function(response, event) {
          this.netzkeProcessDirectResponse(response, event, callback, scope);
        }, this);
      }
    }, this);
  },

  netzkeProcessDirectResponse: function(response, event, callback, scope){
    var callbackParams,
        result; // endpoint response

    // no server exception?
    if (Ext.getClass(event) == Ext.direct.RemotingEvent) {

      // process response and get endpoint return value
      this.netzkeBulkExecute(response);
      result = this.latestResult;

      // endpoint returns an error?
      if (result && result.error) {
        this.netzkeHandleEndpointError(callback, result);
      // no error
      } else {
        if (callback) callback.apply(scope, [result, true]) != false
      }

    // got Direct exception?
    } else {
      this.netzkeHandleDirectError(callback, event);
    }
  },

  netzkeHandleEndpointError: function(callback, result){
    var shouldFireGlobalEvent = true;

    if (callback) {
      shouldFireGlobalEvent = callback.apply(this, [result.error, false]) != false;
    }

    if (shouldFireGlobalEvent) {
      Netzke.GlobalEvents.fireEvent('endpointexception', result.error);
    }
  },

  netzkeHandleDirectError: function(callback, event){
    var shouldFireGlobalEvent = true;

    callbackParams = event;
    callbackParams.type = 'DIRECT_EXCEPTION';

    // First invoke the callback, and if that allows, call generic exception handler
    if (callback) {
      shouldFireGlobalEvent = callback.apply(this, [callbackParams, false]) != false;
    }
    if (shouldFireGlobalEvent) {
      Netzke.GlobalEvents.fireEvent('endpointexception', callbackParams);
    }
  },

  /**
   * Returns direct function by endpoint name and optional component's config (if not provided, component's instance
   * will be used instead)
   * @private
   */
  netzkeGetDirectFunction: function(methodName, config) {
    config = config || this;
    return Netzke.remotingMethods[config.id][methodName];
  },

  /**
   * Array of client configs for each parent component down the tree
   * @private
   */
  netzkeBuildParentConfigs: function() {
    var res = [],
        parent = this;
    while (parent) {
      var cfg = Ext.clone(parent.serverConfig);
      res.unshift(cfg);
      parent = parent.netzkeGetParentComponent();
    }
    return res;
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
   * Dynamically loads nested Netzke component.
   * @param {String} name
   * @param {Object} config Can contain the following keys:
   *   'container' - if specified, the instance (or id) of a panel with the 'fit' layout where the loaded component will be added to; the previously existing component will be destroyed
   *   'append' - if set to +true+, do not clear the container before adding the loaded component
   *   'configOnly' - if set to +true+, do not instantiate/insert the component, instead pass its config to the callback function
   *   'itemId' - specify this unique (per child component) ID in case you want to load multiple instances of the same component; later you can access nested Netzke component by providing +itemId+ to +netzkeGetComponent+.
   *   'serverConfig' - config accessible in the component as +client_config+; this allows reconfiguring components from the client side
   *   'callback' - function that gets called after the component is loaded; it receives the component's instance (or component config if +configOnly+ is set) as parameter; if the function returns +false+, the loaded component will not be automatically inserted or (in case of window) shown.
   *   'scope' - scope for the callback; defaults to the instance of the component.
   *
   * == Examples
   *
   * Loads 'info' and adds it to +this+ container, removing anything from it first:
   *
   *    this.netzkeLoadComponent('info');
   *
   * Loads 'info' and adds it to +win+ container, envoking a callback in +this+ scope, passing it an instance of 'info':
   *
   *    this.netzkeLoadComponent('info', { container: win, callback: function(instance){} });
   *
   * Loads configuration for the 'info' component, envoking a callback in +this+ scope, passing it the loaded config for 'info'.
   *
   *    this.netzkeLoadComponent('info', { configOnly: true, callback: function(config){} });
   *
   * Loads two 'info' instances in different containers and with different configurations:
   *
   *    this.netzkeLoadComponent('info', {
   *      container: 'tab1',
   *      serverConfig: { user: 'john' } // on the server: client_config[:user] == 'john'
   *    });
   *
   *    this.netzkeLoadComponent('info', {
   *      container: 'tab2',
   *      serverConfig: { user: 'bill' } // on the server: client_config[:user] == 'bill'
   *    });
   */
  netzkeLoadComponent: function(name, params){
    var container, serverParams, containerEl;
    params = params || {};

    container = this.netzkeChooseContainer(params);
    serverParams = this.netzkeBuildServerLoadingParams(name, params);

    this.netzkeShowLoadingMask(container);

    // Call the endpoint
    this.deliverComponent(serverParams, function(result, success) {
      this.netzkeHideLoadingMask(container);

      if (success) {
        this.netzkeHandleLoadingResponse(container, result, params);
      } else {
        this.netzkeHandleLoadingError(result);
      }
    });
  },

  /**
   * Handles loading error
   * @protected
   */
  netzkeHandleLoadingError: function(error){
    this.netzkeFeedback(error);
  },

  /**
   * @private
   */
  netzkeBuildServerLoadingParams: function(name, params) {
    return Ext.apply(params.serverParams || {}, {
      name: name,
      client_config: params.serverConfig,
      item_id: params.itemId || name, // TODO: make optional
      cache: Netzke.cache.join() // coma-separated list of xtypes of already loaded classes
    });
  },

  /**
   * Decides, based on params passed to netzkeLoadComponent, what container the component should be loaded into.
   * @protected
   */
  netzkeChooseContainer: function(params) {
    if (!params.container) return this;
    return Ext.isString(params.container) ? Ext.getCmp(params.container) : params.container;
  },

  /**
   * Handles regular server response (may include error)
   * @private
   */
  netzkeHandleLoadingResponse: function(container, result, params){
    if (result.error) {
      this.netzkeFeedback(result.error);
    } else {
      this.netzkeProcessDeliveredComponent(container, result, params);
    }
  },

  /**
   * Processes delivered component
   * @private
   */
  netzkeProcessDeliveredComponent: function(container, result, params){
    var config = result.config, instance, doNotInsert, currentInstance;
    config.netzkeParent = this;

    this.netzkeEvalJs(result.js);
    this.netzkeEvalCss(result.css);

    if (params.configOnly) {
      if (params.callback) params.callback.apply((params.scope || this), [config, params]);
    } else {
      // we must destroy eventual existing component with the same ID
      currentInstance = Ext.getCmp(config.id);
      if (currentInstance) currentInstance.destroy();

      instance = Ext.create(config);

      if (params.callback) {
        doNotInsert = params.callback.apply((params.scope || this), [instance, params]) == false;
      }

      if (doNotInsert) return;

      if (instance.isFloating()) { // windows are not containable
        instance.show();
      } else {
        if (params.replace) {
          this.netzkeReplaceChild(params.replace, instance)
        } else {
          if (!params.append) container.removeAll();
          container.add(instance);
        }
      }
    }
  },

  /**
   * Mask container in which a child component is being loaded
   * @protected
   */
  netzkeShowLoadingMask: function(container){
    if (container.rendered) container.body.mask();
  },

  /**
   * Unmask loading container
   * @protected
   */
  netzkeHideLoadingMask: function(container){
    if (container.rendered) container.body.unmask();
  },

  /**
   * Returns parent Netzke component
   * @private
   */
  netzkeGetParentComponent: function(){
    return this.netzkeParent;
  },

  /**
   * Reloads itself by instructing the parent to call +netzkeLoadComponent+.
   * Note: in order for this to work, the component must be nested in a container with the 'fit' layout.
   * @private
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
   * Given child component and new serverConfig, reloads the component
   * @protected
   */
  netzkeReloadChild: function(child, serverConfig){
    this.netzkeLoadComponent(child.name, {
      configOnly: true,
      serverConfig: serverConfig,
      callback: function(cfg) {
        this.netzkeReplaceChild(child, cfg);
      }
    });
  },

  /**
   * Replaces given (Netzke or Ext JS) component and new config, replaces former with latter, by instructing the parent
   * component to re-insert the component at the same index. Override if you need something more fancy (e.g. active tab
   * when it gets re-inserted)
   * @protected
   */
  netzkeReplaceChild: function(child, config){
    var parent = child.up();
    if (!parent) return;
    var index = parent.items.indexOf(child);
    Ext.suspendLayouts();
    parent.remove(child);
    var res = parent.insert(index, config);
    Ext.resumeLayouts(true);
    return res;
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
  * Returns *instantiated* child component by its relative path, which may contain the 'parent' part to walk _up_ the hierarchy
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
  * Provides a visual feedback.
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
