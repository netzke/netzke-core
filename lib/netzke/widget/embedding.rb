module Netzke
  module Widget
    
    # The following methods are used when a widget is generated stand-alone (as a part of a HTML page)
    module Embedding
      
      # Instantiating
      def js_widget_instance
        %Q{Netzke.page.#{name.jsonify} = new #{self.class.js_full_class_name}(#{js_config.to_nifty_json});}
      end

      # Rendering
      def js_widget_render
        %Q{Netzke.page.#{name.jsonify}.render("#{name.to_s.split('_').join('-')}-netzke");} unless self.class.js_xtype == "netzkewindow"
      end

      # Container for rendering
      def js_widget_html
        %Q{<div id="#{name.to_s.split('_').join('-')}-netzke" class="netzke-widget"></div>}
      end
      
    end
  end
end