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

window.clickButton = (id) ->
  btn = Ext.ComponentQuery.query('button[text="' + id + '"]')[0]
  throw "Button " + id + " not found" if !btn
  btn.btnEl.dom.click()

window.headerWithTitle = (title) ->
  Ext.ComponentQuery.query('header[title="'+title+'"]')[0]

# Closes the first found window
window.closeWindow = ->
  Ext.ComponentQuery.query("window[hidden=false]")[0].close()

window.expectToSee = (text) ->
  el = Ext.DomQuery.select("*:contains(" + text + ")")[0]
  throw "Error: expected to find an element containing \"" + text + "\"" if !el

window.expectNotToSee = (text) ->
  el = Ext.DomQuery.select("*:contains(" + text + ")")[0]
  throw "Error: didn't expect to find an element containing \"" + text + "\"" if el
