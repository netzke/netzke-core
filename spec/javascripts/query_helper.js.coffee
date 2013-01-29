Ext.apply window,
  currentPanelTitle: ->
    panel = Ext.ComponentQuery.query('panel[hidden=false]')[0]
    throw "Panel not found" if !panel
    panel.getHeader().title

  header: (title) ->
    Ext.ComponentQuery.query('header[title="'+title+'"]')[0]

  panelWithContent: (text) ->
    Ext.DomQuery.select("div.x-panel-body:contains(" + text + ")")[0]

  button: (text) ->
    Ext.ComponentQuery.query("button[text='"+text+"']")[0]

  tool: (type) ->
    Ext.ComponentQuery.query("tool[type='"+type+"']")[0]

  component: (id) ->
    Ext.ComponentQuery.query("panel[id='"+id+"']")[0]

  somewhere: (text) ->
    Ext.DomQuery.select("*:contains(" + text + ")")[0]

# alias
window.anywhere = window.somewhere
