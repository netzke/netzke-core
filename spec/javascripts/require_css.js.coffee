describe "RequireCss component", ->
  it "should hide its body by applying extra CSS", ->
    expectInvisibleBodyOf component "require_css"
