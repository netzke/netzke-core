module Netzke
  class ActionConfig < ActiveSupport::OrderedOptions
    def initialize(name, component)
      name = name.to_s

      i18n_id = component.i18n_id

      i18n_text = I18n.t("#{i18n_id}.actions.#{name}", :default => "")
      i18n_tooltip = I18n.t("#{i18n_id}.actions.#{name}_tooltip", :default => "")

      self.text = i18n_text.presence || name.humanize
      self.tooltip = i18n_tooltip.presence || name.humanize

      #if c[:icon].is_a?(Symbol)
        #c[:icon] = uri_to_icon(c[:icon])
      #end

      # If we have an I18n for it, use it
      #default_text = I18n.t(i18n_id + ".actions." + c[:name], :default => "")
      #c[:text] = default_text if default_text.present?
      #default_tooltip = I18n.t(i18n_id + ".actions." + c[:name] + "_tooltip", :default => default_text)
      #c[:tooltip] = default_tooltip if default_tooltip.present?
    end

    def icon=(path)
      self[:icon] = path.is_a?(Symbol) ? uri_to_icon(path) : path
    end

  private

    def uri_to_icon(icon)
      Netzke::Core.with_icons ? [Netzke::Core.controller.config.relative_url_root, Netzke::Core.icons_uri, '/', icon.to_s, ".png"].join : nil
    end
  end
end
