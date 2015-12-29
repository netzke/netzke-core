describe "CssInclusion component", ->
  it "hides its body by applying extra CSS", ->
    expectInvisibleBodyOf component "css_inclusion"
