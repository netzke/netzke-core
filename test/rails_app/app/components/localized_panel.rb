class LocalizedPanel < Netzke::Base
  # This action will be translated per-class basis if the translation is available, and fall back to the default when it's not.
  action :action_one

  # If you want action's text to be inheritable, this is what you shold do:
  action :action_two do
    {:text => I18n.t('localized_panel.action_two')}
  end

  js_translate :property_one, :property_two

  js_property :bbar, [:action_one.action, :action_two.action]

  def configuration
    super.tap do |c|
      c[:title] = I18n.t('localized_panel.title')
    end
  end

  js_method :on_render, <<-JS
    function(ct){
      Netzke.classes.LocalizedPanel.superclass.onRender.call(this, ct);

      this.body.update(this.i18n.propertyOne + ", " + this.i18n.propertyTwo);
    }
  JS

end
