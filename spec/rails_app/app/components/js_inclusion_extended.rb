class JsInclusionExtended < JsInclusion
  client_class do |c|
    c.title = "JsInclusionExtended component"
    c.mixin :some_method_set
  end
end
