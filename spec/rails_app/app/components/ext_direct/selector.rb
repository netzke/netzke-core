module ExtDirect
  class Selector < Netzke::Base
    client_class do |c|
      c.extend = "Ext.FormPanel"
      c.body_padding = 5

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
