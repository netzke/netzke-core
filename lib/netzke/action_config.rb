module Netzke
  class ActionConfig < ActiveSupport::OrderedOptions
    def initialize(name, component)
      name = name.to_s
      i18n_id = component.i18n_id

      i18n_text = I18n.t("#{i18n_id}.actions.#{name}", :default => "")
      self.text = i18n_text.presence || name.humanize

      i18n_tooltip = I18n.t("#{i18n_id}.actions.#{name}_tooltip", :default => "")
      self.tooltip = i18n_tooltip.presence || name.humanize
    end

    def icon=(path)
      self[:icon] = path.is_a?(Symbol) ? Netzke::Core.uri_to_icon(path) : path
    end
  end
end
