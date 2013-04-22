/**
This file gets loaded along with the rest of Ext library at the initial load. It is common for both Ext JS and Touch; Ext JS-specific stuff is in ext.js.

At this time the following constants have been set by Rails:

  Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
  Netzke.RelativeExtUrl - URL to ext files
  Netzke.ControllerUrl - NetzkeController URL
*/

// Initial stuff
Netzke.classNamespace = 'Netzke.classes'; // TODO: pass from Ruby
Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext
Ext.ns('Netzke.page'); // namespace for all component instances on the page
Ext.ns(Netzke.classNamespace); // namespace for all component classes
Ext.ns('Netzke.classes.Core'); // namespace for Core mixins

Netzke.deprecationWarning = function(msg){
  if (typeof console == 'undefined') {
    // no console defined
  } else {
    console.info("Netzke: " + msg);
  }
};

Netzke.warning = Netzke.deprecationWarning;

Netzke.exception = function(msg) {
  throw("Netzke: " + msg);
};

// Used in testing
if( Netzke.nLoadingFixRequests == undefined ){
  Netzke.nLoadingFixRequests=0;
  Ext.Ajax.on('beforerequest',    function(conn,opt) { Netzke.nLoadingFixRequests+=1; });
  Ext.Ajax.on('requestcomplete',  function(conn,opt) { Netzke.nLoadingFixRequests-=1; });
  Ext.Ajax.on('requestexception', function(conn,opt) { Netzke.nLoadingFixRequests-=1; });
  Netzke.ajaxIsLoading = function() { return Netzke.nLoadingFixRequests > 0; };
}

// Used in testing, too
Netzke.runningRequests = 0;
Netzke.isLoading=function () {
  return Netzke.runningRequests != 0;
}

// xtypes of cached Netzke classes
Netzke.cache = [];

Ext.define("Netzke.classes.Core.Mixin", {
  isNetzke: true, // to distinguish Netzke components from regular Ext components

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
        if(args instanceof Object && Ext.isEmpty(args))
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
  }
});
