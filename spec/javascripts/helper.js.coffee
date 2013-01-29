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

  currentPanelTitle: ->
    panel = Ext.ComponentQuery.query('panel[hidden=false]')[0]
    throw "Panel not found" if !panel
    panel.getHeader().title

  header: (title) ->
    Ext.ComponentQuery.query('header[title="'+title+'"]')[0]

  # Closes the first found window
  closeWindow: ->
    Ext.ComponentQuery.query("window[hidden=false]")[0].close()

  expectToSee: (el) ->
    expect(el).to.be.ok()

  expectToNotSee: (el) ->
    expect(el).to.not.be.ok()

  panelWithContent: (text) ->
    Ext.DomQuery.select("div.x-panel-body:contains(" + text + ")")[0]

  button: (text) ->
    Ext.ComponentQuery.query("button[text='"+text+"']")[0]

  somewhere: (text) ->
    Ext.DomQuery.select("*:contains(" + text + ")")[0]

  expectDisabled: (cmp) ->
    expect(cmp.isDisabled()).to.be(true)

  click: (cmp) ->
    if (cmp.isXType('tool'))
      # a hack needed for tools
      el = cmp.toolEl
    else
      el = cmp.getEl()

    el.dom.click()

  tool: (type) ->
    Ext.ComponentQuery.query("tool[type='"+type+"']")[0]

  component: (id) ->
    Ext.ComponentQuery.query("panel[id='"+id+"']")[0]

  expectInvisibleBodyOf: (cmp) ->
    expect(cmp.body.isVisible()).to.be false

# alias
window.anywhere = window.somewhere
