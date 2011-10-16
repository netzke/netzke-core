class ExtendedServerCaller < ServerCaller
  title "Extended Server Caller"

  js_method :on_bug_server, <<-JS
    function(){
      this.callParent();
      var bottomBar = this.getDockedItems()[1] || this.getDockedItems()[0]; // Hacky-hacky... better way to surely get the bottom bar?
      bottomBar.add({text: "Added" + " by extended Server Caller"});
    }
  JS

  # Overriding the :whats_up endpoint from ServerCaller
  def whats_up_endpoint(params)
    super.tap do |s|
      s[:set_title] = s[:set_title] + ", shiny weather"
    end
  end

end