module ExtDirect
  class Selector < Netzke::Base
    js_base_class "Ext.FormPanel"

    js_property :padding, 5

    action :update

    def configuration
      super.merge({
        :items => [{:name => "user", :field_label => "User", :xtype => :textfield}],
        :bbar => [:update.action]
      })
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
