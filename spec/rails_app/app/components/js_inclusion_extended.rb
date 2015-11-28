class JsInclusionExtended < JsInclusion
  client_class do |c|
    c.title = "JsInclusionExtended component"
    c.include :some_method_set
  end
end
