describe "CssInclusion component", ->
  it "should hide its body by applying extra CSS", ->
    expectInvisibleBodyOf component "css_inclusion"
