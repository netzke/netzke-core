class ExtendedServerCaller < ServerCaller

  js_properties :title => "Extended Server Caller"

  js_method :on_bug_server, <<-JS
    function(){
      #{js_full_class_name}.superclass.onBugServer.call(this);
      this.getBottomToolbar().addButton({text: "Added" + " by extended Server Caller"});
      this.getBottomToolbar().doLayout();
    }
  JS

  def whats_up_endpoint(params)
    orig = super
    orig.merge(:set_title => orig[:set_title] + ", shiny weather")
  end

end