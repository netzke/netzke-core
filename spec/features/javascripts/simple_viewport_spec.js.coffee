describe "SimpleViewport component", ->
  it "loads its window child component", (done) ->
    click button "Load window"
    wait().then ->
      expectToSee header "Window title"
      done()
