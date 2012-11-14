# Not used in automatic tests
class SimpleFormWithFileUpload < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.form.Panel"
    c.body_padding = 10
    c.on_submit = <<-JS
      function(){

        var msg = function(title, msg) {
            Ext.Msg.show({
                title: title,
                msg: msg,
                minWidth: 200,
                modal: true,
                icon: Ext.Msg.INFO,
                buttons: Ext.Msg.OK
            });
        };

        var me = this;

        this.getForm().submit({
          url: this.netzkeEndpointUrl('server_submit'),
          success: function(fp, o){
            msg("Success", 'Your file is uploaded!');
        },
          failure: function(){msg("Failure", 'Server did not inform us about success');}
        });
      }
    JS
  end

  action :submit

  def configure(c)
    super
    c.items = [{ xtype: :filefield, emptyText: 'Select an image', fieldLabel: 'Photo', buttonText: '...' }]

    c.bbar = [:submit]
  end

  endpoint :server_submit do |params, this|
    # because this endpoint wasn't called in the normal way, we cannot do anything like this (it won't have any effect):
    # this.set_title('File uploaded')

    # But this will define whether the client is informed about success or not:
    this.success = true
  end
end
