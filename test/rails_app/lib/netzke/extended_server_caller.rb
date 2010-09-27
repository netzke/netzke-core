module Netzke
  class ExtendedServerCaller < ServerCaller
    js_properties :title => "Extended Server Caller"
    
    js_method :bug_server, <<-JS
      function(){
        #{js_full_class_name}.superclass.bugServer.call(this);
        this.getBottomToolbar().addButton({text: "Added" + " by extended Server Caller"});
        this.getBottomToolbar().doLayout();
      }
    JS

    api :whats_up
    def whats_up(params)
      {:set_title => super(params)[:set_title] + ", shiny weather"}
    end

  end
end