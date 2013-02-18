describe "LoadedCssInclusion component", ->
  it "should load CssInclusion component with its body hidden", (done) ->
    click button "Load CssInclusion"
    wait ->
      expectInvisibleBodyOf component "loaded_css_inclusion__css_inclusion"
      done()
