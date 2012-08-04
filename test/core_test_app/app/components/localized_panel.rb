class LocalizedPanel < Netzke::Base
  # This action will be translated per-class basis if the translation is available, falling back to the default
  action :action_one

  action :action_two do |a|
    a.text = I18n.t('localized_panel.action_two')
  end

  action :action_three

  js_configure do |c|
    c.translate :property_one, :property_two

    c.on_render = <<-JS
      function(ct){
        Netzke.classes.LocalizedPanel.superclass.onRender.call(this, ct);

        this.body.update(this.i18n.propertyOne + ", " + this.i18n.propertyTwo);
      }
    JS

    c.on_action_three = <<-JS
      function(){
        var mask = new Ext.LoadMask(this.body);
        mask.show();
      }
    JS
  end

  def configure
    super
    config.title = I18n.t('localized_panel.title')
    config.bbar = [:action_one, :action_two, :action_three]
  end
end
