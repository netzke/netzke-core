class WindowWithSimpleComponent < SimpleWindow
  js_property :layout, :fit

  def items
    [
      { netzke_component: :simple_component }
    ]
  end

  component :simple_component
end
