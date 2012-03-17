class LocalizedPanel < Netzke::Base
  # This action will be translated per-class basis if the translation is available, and fall back to the default when it's not.
  action :action_one

  # If you want action's text to be inheritable, this is what you shold do:
  action :action_two do
    {:text => I18n.t('localized_panel.action_two')}
  end

  action :action_three

  js_translate :property_one, :property_two

  js_property :bbar, [:action_one.action, :action_two.action, :action_three.action]

  def configure!
    config.title = I18n.t('localized_panel.title')
  end

  js_method :on_render, <<-JS
    function(ct){
      Netzke.classes.LocalizedPanel.superclass.onRender.call(this, ct);

      this.body.update(this.i18n.propertyOne + ", " + this.i18n.propertyTwo);
    }
  JS

  js_method :on_action_three, <<-JS
    function(){
      var mask = new Ext.LoadMask(this.body);
      mask.show();
    }
  JS

end
