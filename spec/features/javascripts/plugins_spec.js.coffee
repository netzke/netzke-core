describe "Plugins component", ->
  it "calls its server part as defined in PluginWithEndpoints", (done) ->
    click tool 'gear'
    wait ->
      expectToSee header "Response from server side of PluginWithEndpoints"
      done()

  it "triggers an action injected by PluginWithActions", ->
    click button 'Update title'
    expectToSee header "Title updated by PluginWithActions"

  it "shows a window pre-loaded by PluginWithComponents", (done) ->
    click tool 'help'
    wait ->
      expectToSee header "Window added by PluginWithComponents"
      done()
