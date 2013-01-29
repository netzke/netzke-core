Ext.Ajax.on 'beforerequest', ->
  Netzke.ajaxCount = window.ajaxCount || 0
  Netzke.ajaxCount += 1

Ext.Ajax.on 'requestcomplete', ->
  Netzke.ajaxCount -= 1

window.wait = (callback) ->
  i = 0
  id = setInterval ->
    i += 1
    if i >= 100
      clearInterval(id)
      callback.call()

    # this way we ensure another 20ms cycle before we issue a callback
    i = 100 if Netzke.ajaxCount == 0

  , 20

window.currentPanelTitle = ->
  panel = Ext.ComponentQuery.query('panel[hidden=false]')[0]
  throw "Panel not found" if !panel
  panel.getHeader().title

window.header = (title) ->
  Ext.ComponentQuery.query('header[title="'+title+'"]')[0]

# Closes the first found window
window.closeWindow = ->
  Ext.ComponentQuery.query("window[hidden=false]")[0].close()

window.expectToSee = (el) ->
  expect(el).to.be.ok()

window.expectToNotSee = (el) ->
  expect(el).to.not.be.ok()

window.panelWithContent = (text) ->
  Ext.DomQuery.select("div.x-panel-body:contains(" + text + ")")[0]

window.button = (text) ->
  Ext.ComponentQuery.query("button[text='"+text+"']")[0]

window.somewhere = (text) ->
  Ext.DomQuery.select("*:contains(" + text + ")")[0]

window.anywhere = window.somewhere

window.expectDisabled = (cmp) ->
  expect(cmp.isDisabled()).to.be(true)

window.click = (cmp) ->
  if (cmp.isXType('tool'))
    # a hack needed for tools
    el = cmp.toolEl
  else
    el = cmp.getEl()

  el.dom.click()

window.tool = (type) ->
  Ext.ComponentQuery.query("tool[type='"+type+"']")[0]

window.component = (id) ->
  Ext.ComponentQuery.query("panel[id='"+id+"']")[0]

window.expectInvisibleBodyOf = (cmp) ->
  expect(cmp.body.isVisible()).to.be false
