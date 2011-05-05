module Netzke
  class ExtComponent
    attr_accessor :name

    def initialize(name, config = {})
      @name = name
      @config = config
    end

    def config
      @config ||= {}
    end

    # Rendering
    def js_component_render
      %Q{Ext.ComponentManager.create("#{js_full_class_name}", #{config.to_nifty_json}).render("ext-#{name.to_s.split('_').join('-')}");}
    end

    # Container for rendering
    def js_component_html
      %Q{<div id="ext-#{name.to_s.split('_').join('-')}" class="ext-component"></div>}
    end

  end
end
