class ExtendedServerCaller < ServerCaller
  
  js_properties :title => "Extended Server Caller"
  
  js_method :bug_server, <<-JS
    function(){
      #{js_full_class_name}.superclass.bugServer.call(this);
      this.getBottomToolbar().addButton({text: "Added" + " by extended Server Caller"});
      this.getBottomToolbar().doLayout();
    }
  JS

  def whats_up(params)
    orig = super
    orig.merge(:set_title => orig[:set_title] + ", shiny weather")
  end
  
end