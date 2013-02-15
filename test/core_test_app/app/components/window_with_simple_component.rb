# Used in DynamicLoading
class WindowWithSimpleComponent < SimpleWindow
  js_configure do |c|
    c.layout = :fit
  end

  def configure(c)
    c.items = [:simple_component]
    super
  end

  component :simple_component do |c|
    c.title = "Simple Component Inside Window"
  end
end
