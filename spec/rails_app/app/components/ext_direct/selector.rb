module ExtDirect
  class Selector < Netzke::Base
    js_configure do |c|
      c.extend = "Ext.FormPanel"
      c.body_padding = 5

      c.init_component = <<-JS
        function(){
          this.callParent();
        }
      JS

      c.on_update = <<-JS
        function(){
          this.fireEvent('userupdate', this.getForm().findField('user').getValue());
        }
      JS
    end

    action :update

    def configure(c)
      super
      c.items = [{:name => "user", :field_label => "User", :xtype => :textfield}]
      c.bbar = [:update]
    end
  end
end
