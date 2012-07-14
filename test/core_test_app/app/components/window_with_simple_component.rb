class WindowWithSimpleComponent < SimpleWindow
  js_configure do |c|
    c.layout = :fit
  end

  def items
    [
      { netzke_component: :simple_component }
    ]
  end

  component :simple_component do |c|
    c.title = "Simple Component Inside Window"
  end
end
