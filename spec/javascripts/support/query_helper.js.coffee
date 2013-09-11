# Query helpers will return a string denoting what was searched for, when a component/element itself could not be found. This can be used by other helpers to display a more informative error.
# KNOW ISSUE: if the passed parameter contains symbols like "():,.", it results in an invalid query.
Ext.apply window,
  header: (title) ->
    Ext.ComponentQuery.query('header{isVisible(true)}[title="'+title+'"]')[0] || 'header ' + title

  tab: (title) ->
    Ext.ComponentQuery.query('tab[text="'+title+'"]')[0] || 'tab ' + title

  panelWithContent: (text) ->
    Ext.DomQuery.select("div.x-panel-body:contains(" + text + ")")[0] || 'panel with content ' + text

  button: (text) ->
    Ext.ComponentQuery.query("button{isVisible(true)}[text='"+text+"']")[0] || "button " + text

  tool: (type) ->
    Ext.ComponentQuery.query("tool{isVisible(true)}[type='"+type+"']")[0] || 'tool ' + type

  component: (id) ->
    Ext.ComponentQuery.query("panel{isVisible(true)}[id='"+id+"']")[0] || 'component ' + id

  somewhere: (text) ->
    Ext.DomQuery.select("*:contains(" + text + ")")[0] || 'anywhere ' + text

  # used as work-around for the invalid query problem
  currentPanelTitle: ->
    panel = Ext.ComponentQuery.query('panel[hidden=false]')[0]
    throw "Panel not found" if !panel
    panel.getHeader().title

# alias
window.anywhere = window.somewhere
