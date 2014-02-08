Ext.Ajax.on 'beforerequest', ->
  Netzke.ajaxCount = window.ajaxCount || 0
  Netzke.ajaxCount += 1

Ext.Ajax.on 'requestcomplete', ->
  Netzke.ajaxCount -= 1

Ext.apply window,
  wait: (callback) ->
    i = 0
    id = setInterval ->
      i += 1
      if i >= 100
        clearInterval(id)
        callback.call()

      # this way we ensure another 20ms cycle before we issue a callback
      i = 100 if Netzke.ajaxCount == 0
    , 20

  click: (cmp) ->
    if Ext.isString(cmp)
      throw "Could not locate " + cmp
    else
      if (cmp.isXType('tool'))
        # a hack needed for tools
        el = cmp.toolEl
      else
        el = cmp.getEl()

      el.dom.click()

  # Closes the first found window
  closeWindow: ->
    Ext.ComponentQuery.query("window[hidden=false]")[0].close()
