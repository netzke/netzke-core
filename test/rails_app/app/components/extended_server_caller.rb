class ExtendedServerCaller < ServerCaller
  js_properties :title => "Extended Server Caller"

  js_method :on_bug_server, <<-JS
    function(){
      this.callParent();
      var bottomBar = this.getDockedItems()[1];
      bottomBar.add({text: "Added" + " by extended Server Caller"});
    }
  JS

  def whats_up_endpoint(params)
    super.tap do |s|
      s[:set_title] = s[:set_title] + ", shiny weather"
    end
  end

end