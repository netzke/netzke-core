module Netzke::Core
  # This class is responsible for configuring an action. It is passed as a block parameter to the +action+ DSL method:
  #
  #   class MyComponent < Netzke::Base
  #     action :do_something do |c|
  #       c.text = "Do it!"
  #       c.tooltip = "Do something"
  #       c.icon = :tick
  #     end
  #   end
  class ActionConfig < ActiveSupport::OrderedOptions
    def initialize(name, component)
      @component = component
      @name = name.to_s
      @text = @tooltip = @icon = ""

      build_localized_attributes

      self.name = @name
      self.text = @text.presence || @name.humanize
      self.tooltip = @tooltip.presence || @name.humanize
      self.icon = @icon.to_sym if @icon.present?
    end

    def icon=(path)
      self[:icon] = path.is_a?(Symbol) ? Netzke::Base.uri_to_icon(path) : path
    end

  private

    def build_localized_attributes
      @component.class.netzke_ancestors.each do |c|
        i18n_id = c.i18n_id
        @text = I18n.t("#{i18n_id}.actions.#{@name}.text", default: "").presence || @text
        @tooltip = I18n.t("#{i18n_id}.actions.#{@name}.tooltip", default: "").presence || @tooltip
        @icon = I18n.t("#{i18n_id}.actions.#{@name}.icon", default: "").presence || @icon
      end
    end
  end
end
