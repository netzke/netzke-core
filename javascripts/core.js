Ext.BLANK_IMAGE_URL = "/extjs/resources/images/default/s.gif";
Ext.componentCache = {};

Ext.namespace('Ext.netzke');

// to comply with Rails' forgery protection
Ext.Ajax.extraParams = {
    'authenticity_token': Ext.authenticityToken
};

// helper method to do multiple Ext.apply's
Ext.chainApply = function(objectArray){
	var res = {};
	Ext.each(objectArray, function(obj){Ext.apply(res, obj)});
	return res;
};

// implementation of totalProperty, successProperty and root configuration options for ArrayReader
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
	widgetInit:function(config){
    this.app = Ext.getCmp('application');
    if (config.tools) Ext.each(config.tools, function(i){i.on.click = this[i.on.click].createDelegate(this)}, this);
    if (config.actions) Ext.each(config.actions, function(i){i.handler = this[i.handler].createDelegate(this);}, this);
	},

	setEvents: function(){
		this.on('beforedestroy', function(){
			// clean-up menus
			if (this.app && !!this.app.unhostMenus) {
				// alert('beforedestroy');
				this.app.unhostMenus(this)
			}
		}, this);
		
		this.on('render', this.onWidgetLoad, this);
	},

	feedback:function(msg){
		if (this.initialConfig.quiet) return false;
		if (this.app && !!this.app.showFeedback) {
			this.app.showFeedback(msg)
		} else {
			// there's no application to show the feedback - so, we do it ourselves
			if (typeof msg == 'string'){
				alert(msg)
			} else {
				var compoundResponse = ""
				Ext.each(msg, function(m){
          compoundResponse += m.msg + "\n"
        })
				if (compoundResponse != "") alert(compoundResponse);
			}
		};
	},

	addMenus:function(menus){
		if (this.app && !!this.app.hostMenu) {
			Ext.each(menus, function(menu){this.app.hostMenu(menu, this)}, this)
		}
	},
	
	onWidgetLoad:Ext.emptyFn // gets overridden
};

// Make Panel with layout 'fit' capable to dynamically load widgets
Ext.override(Ext.Panel, {
	getWidget: function(){
		return this.items.get(0)
	},
	
	loadWidget: function(url, params){
		if (!params) params = {}
		
		this.remove(this.getWidget()); // first delete previous widget
		
		// we will let the server know which components we have cached
		var cachedComponentNames = [];
		for (name in Ext.componentCache) {
			cachedComponentNames.push(name);
		}
		
		this.disable(); // to visually emphasize loading
		
		Ext.Ajax.request(
			{url:url, params:Ext.apply(params, {components_cache:Ext.encode(cachedComponentNames)}), script:false, callback:function(panel, success, response){
				var response = Ext.decode(response.responseText);
				if (response['classDefinition']) eval(response['classDefinition']); // evaluate widget's class if it was sent

				response.config.parent = this // we might want to know the parent panel in advance (e.g. to know its size)
				var instance = new Ext.componentCache[response.config.widgetClassName](response.config)
				
				this.add(instance);
				this.doLayout();
				this.enable();
			}, scope:this}
		)
		
	}
});
