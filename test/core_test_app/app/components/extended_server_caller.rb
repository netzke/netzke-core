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
  endpoint :whats_up do |params, this|
    super(params, this)

    this.set_title(this.set_title[0] + ", shiny weather")
  end
end
