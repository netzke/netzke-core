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
    
    # def js_widget_instance
    #   %Q{var #{name.jsonify} = ;}
    # end
    
    # Rendering
    def js_widget_render
      %Q{Ext.ComponentMgr.create(#{config.to_nifty_json}).render("ext-#{name.to_s.split('_').join('-')}");}
    end

    # Container for rendering
    def js_widget_html
      %Q{<div id="ext-#{name.to_s.split('_').join('-')}" class="ext-component"></div>}
    end
    
  end
end