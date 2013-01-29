Ext.apply window,
  expectToSee: (el) ->
    expect(el).to.be.ok()

  expectToNotSee: (el) ->
    expect(el).to.not.be.ok()

  expectDisabled: (cmp) ->
    expect(cmp.isDisabled()).to.be(true)

  expectInvisibleBodyOf: (cmp) ->
    expect(cmp.body.isVisible()).to.be false
