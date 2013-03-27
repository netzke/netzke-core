Ext.apply window,
  expectToSee: (el) ->
    expect(Ext.isObject(el) || Ext.isElement(el)).to.be.ok()

  expectToNotSee: (el) ->
    expect(Ext.isString(el)).to.be.ok()

  expectDisabled: (cmp) ->
    throw cmp + " not found" if Ext.isString(cmp)
    expect(cmp.isDisabled()).to.be(true)

  expectInvisibleBodyOf: (cmp) ->
    throw cmp + " not found" if Ext.isString(cmp)
    expect(cmp.body.isVisible()).to.be false
