class Localization < Netzke::Base
  # This action will be translated per-class basis if the translation is available, falling back to the default
  action :action_one

  action :action_two do |a|
    a.text = I18n.t('localization.action_two')
  end

  action :action_three

  # Displayes localized JS properties in the header
  action :show_properties

  client_class do |c|
    c.translate :property_one, :property_two
  end

  def configure(c)
    super
    c.title = I18n.t('localization.title')
    c.bbar = [:action_one, :action_two, :action_three, :show_properties]
  end
end
