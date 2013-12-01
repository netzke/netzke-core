class Localization < Netzke::Base
  # This action will be translated per-class basis if the translation is available, falling back to the default
  action :action_one

  action :action_two do |a|
    a.text = I18n.t('localization.action_two')
  end

  action :action_three

  # Displayes localized JS properties in the header
  action :show_properties

  js_configure do |c|
    c.translate :property_one, :property_two

    c.on_show_properties = <<-JS
      function(ct){
        this.setTitle(this.i18n.propertyOne + " - " + this.i18n.propertyTwo);
      }
    JS

    c.on_action_three = <<-JS
      function(){
        var mask = new Ext.LoadMask(this.body);
        mask.show();
      }
    JS
  end

  def configure(c)
    super
    c.title = I18n.t('localization.title')
    c.bbar = [:action_one, :action_two, :action_three, :show_properties]
  end
end
