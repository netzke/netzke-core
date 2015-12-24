class SimpleViewport < Netzke::Base
  client_class do |c|
    c.extend = "Ext.container.Viewport"
  end

  # In Ext 4.1 calling `render` on a viewport causes an error:
  #
  #   TypeError: protoEl is null
  def js_component_render
    ""
  end

  def configure(c)
    super
    c.items = [
      {
        layout: :fit,
        tbar: [:load_window],
        items: [] # we'll load the initial component dynamically later
      }
    ]
  end

  action :load_window

  component :simple_window do |c|
    c.title = 'Window title'
    c.width = 200
  end
end
