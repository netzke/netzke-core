module ExtDirect
  class Selector < Netzke::Base
    js_base_class "Ext.FormPanel"

    js_property :padding, 5

    action :update

    def configure
      super
      @config[:items] = [{:name => "user", :field_label => "User", :xtype => :textfield}]
      @config[:bbar] = [:update]
    end

    js_method :init_component, <<-JS
      function(){
        Netzke.classes.ExtDirect.Selector.superclass.initComponent.call(this);
        this.addEvents('userupdate');
      }
    JS


    js_method :on_update, <<-JS
      function(){
        this.fireEvent('userupdate', this.getForm().findField('user').getValue());
      }
    JS

  end
end
