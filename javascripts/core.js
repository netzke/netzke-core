/*
 * This file gets loaded along with the rest of Ext library at the initial load
 * At this time the following constants have been set by Rails:
 *
 *   * Netzke.RelativeUrlRoot - set to ActionController::Base.config.relative_url_root
 *   * Netzke.RelativeExtUrl - URL to ext files
 *   * Netzke.ControllerUrl - NetzkeController URL
*/

Ext.ns('Ext.netzke'); // namespace for extensions that depend on Ext JS
Ext.ns('Netzke.page'); // namespace for all component instances on the page
Ext.ns('Netzke.classes'); // namespace for component classes

Netzke.warning = function(msg){
  if (typeof console != 'undefined') {
    console.info("Netzke: " + msg);
  }
};

Netzke.deprecationWarning = Netzke.warning;

Netzke.exception = function(msg) {
  throw("Netzke: " + msg);
};

// Check Ext JS version: both major and minor versions must be the same
(function(){
  var requiredVersionMajor = 6,
      requiredVersionMinor = 5,
      extVersion = Ext.getVersion('extjs'),
      currentVersionMajor = extVersion.getMajor(),
      currentVersionMinor = extVersion.getMinor(),
      requiredString = "" + requiredVersionMajor + "." + requiredVersionMinor + ".x";

  if (requiredVersionMajor != currentVersionMajor || requiredVersionMinor != currentVersionMinor) {
    Netzke.warning("Ext JS " + requiredString + " required (you have " + extVersion.toString() + ").");
  }
})();

// Netzke global event emitter
Ext.define('Netzke.GlobalEvents', {
    extend: 'Ext.mixin.Observable',
    singleton: true
});

// xtypes of cached Netzke classes
Netzke.cache = [];

// Because of Netzke's double-underscore notation, Ext.TabPanel should have a different id-delimiter (yes, this must be in netzke-core)
Ext.TabPanel.prototype.idDelimiter = "___";

// Enable quick tips
Ext.QuickTips.init();

// Used in testing
if( Netzke._pendingRequests == undefined ){
  Netzke._pendingRequests=0;
  Ext.Ajax.on('beforerequest',    function(conn, opt) { Netzke._pendingRequests += 1; });
  Ext.Ajax.on('requestcomplete',  function(conn, opt) { Netzke._pendingRequests -= 1; });
  Ext.Ajax.on('requestexception', function(conn, opt) { Netzke._pendingRequests -= 1; });
  Netzke.ajaxIsLoading = function() { return Netzke._pendingRequests > 0; };
}
