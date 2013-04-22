class JsInclusionExtended < JsInclusion
  js_configure do |c|
    c.title = "JsInclusionExtended component"
    c.mixin :some_method_set
  end
end
