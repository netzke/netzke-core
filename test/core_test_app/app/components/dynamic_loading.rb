# TODO: some functionality (one that is calling doNothing) does not belong here, as it loads no componens, but rather to ServerCaller. Move it there.
class DynamicLoading < Netzke::Base
  js_configure do |c|
    c.mixin
  end

  component :simple_component

  component :component_loaded_in_window do |c|
    c.klass = SimpleComponent
    c.title = "Component loaded in window"
  end

  component :window_with_simple_component do |c|
    c.width = 400
    c.height = 300
  end

  component :composition

  component :inaccessible do |c|
    c.klass = Netzke::Core::Panel
    c.excluded = true
  end

  component :self_reloading

  # this action is using netzkeLoadComponent "special" callback
  action :load_with_feedback

  action :load_component

  action :load_in_window

  action :load_window_with_simple_component

  action :load_composite

  action :load_with_params

  action :config_only

  action :non_existing_component do |a|
    a.text = "Non-existing component"
  end

  action :inaccessible

  action :load_self_reloading

  def configure(c)
    super
    c.bbar = [:load_component, :load_in_window, :load_with_feedback, :load_window_with_simple_component, :load_composite, :load_with_params, :non_existing_component, :inaccessible, :config_only, :load_self_reloading]
  end

  # endpoint :deliver_component do |params, this|
  #   if params[:name] == "simple_component" && params[:title]
  #     components[:simple_component].merge!(:title => params[:title])
  #   end
  #   super(params, this)
  # end
end
