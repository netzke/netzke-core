describe "SimpleViewport component", ->
  it "loads its window child component", ->
    click button "Load window"
    wait().then ->
      expectToSee header "Window title"
