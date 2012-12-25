module Netzke::Core
  # The following methods are used when a component is generated stand-alone (as a part of a HTML page)
  module Embedding
    # Instantiating
    def js_component_instance
      %Q{Netzke.page.#{name.to_s.camelize(:lower)} = Ext.create("#{self.class.js_config.class_alias}", #{js_config.netzke_jsonify.to_json});}
    end

    # Rendering
    def js_component_render
      %Q{Netzke.page.#{name.to_s.camelize(:lower)}.render("#{name.to_s.split('_').join('-')}-netzke");} unless self.class.js_config.xtype == "netzkewindow"
    end

    # Container for rendering
    def js_component_html
      %Q{<div id="#{name.to_s.split('_').join('-')}-netzke" class="netzke-component"></div>}
    end
  end
end
