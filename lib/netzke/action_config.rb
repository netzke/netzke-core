module Netzke
  class ActionConfig < ActiveSupport::OrderedOptions
    def initialize(name, component)
      name = name.to_s
      i18n_id = component.i18n_id

      i18n_text = I18n.t("#{i18n_id}.actions.#{name}.text", :default => "")
      self.text = i18n_text.presence || name.humanize

      i18n_tooltip = I18n.t("#{i18n_id}.actions.#{name}.tooltip", :default => "")
      self.tooltip = i18n_tooltip.presence || name.humanize

      i18n_icon = I18n.t("#{i18n_id}.actions.#{name}.icon", :default => "")
      self.icon = i18n_icon.to_sym if i18n_icon.present?
    end

    def icon=(path)
      self[:icon] = path.is_a?(Symbol) ? Netzke::Core.uri_to_icon(path) : path
    end
  end
end
