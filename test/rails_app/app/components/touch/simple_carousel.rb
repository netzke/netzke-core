module Touch
  class SimpleCarousel < Netzke::Base
    js_base_class "Ext.Carousel"
    config :items => [{html: "Panel One"}, {html: "Panel Two"}]
  end
end
