describe "Plugins component", ->
  it "should be able to call its server part as defined in PluginWithEndpoints", (done) ->
    click tool 'gear'
    wait ->
      expectToSee header "Response from server side of PluginWithEndpoints"
      done()

  it "should be able to trigger an action injected by PluginWithActions", ->
    click button 'Update title'
    expectToSee header "Title updated by PluginWithActions"

  it "should be able to show a window pre-loaded by PluginWithComponents", (done) ->
    click tool 'help'
    wait ->
      expectToSee header "Window added by PluginWithComponents"
      done()
