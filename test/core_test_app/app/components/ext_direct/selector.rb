module ExtDirect
  class Selector < Netzke::Base
    js_configure do |c|
      c.extend = "Ext.FormPanel"
      c.padding = 5

      c.init_component = <<-JS
        function(){
          this.callParent();
          this.addEvents('userupdate');
        }
      JS

      c.on_update = <<-JS
        function(){
          this.fireEvent('userupdate', this.getForm().findField('user').getValue());
        }
      JS
    end

    action :update

    def configure
      super
      config.items = [{:name => "user", :field_label => "User", :xtype => :textfield}]
      config.bbar = [:update]
    end
  end
end
