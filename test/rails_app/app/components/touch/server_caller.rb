module Touch
  class ServerCaller < Netzke::Base
    js_base_class "Ext.Panel"

    def configuration
      super.merge({
        :docked_items => [{:dock => :top, :xtype => :toolbar, :title => 'Server Caller', :items => [
          {:text => "Bug server", :handler => :on_bug_server}
        ]}]
      })
    end

    js_method :on_bug_server, <<-JS
      function(){
        if (!this.maskCmp) this.maskCmp = new Ext.LoadMask(Ext.getBody(), {msg:"Please wait..."});
        this.maskCmp.show();
        this.whatsUp({}, function(){
          this.maskCmp.hide();
        }, this);
      }
    JS

    endpoint :whats_up do |params|
      sleep 1 # for visual testing
      {:update => "Hello from the server!"}
    end
  end
end
