class DynamicLoading < Netzke::Base
  component :simple_component

  component :component_loaded_in_window do |c|
    c.klass = SimpleComponent
    c.title = "Component loaded in window"
  end

  component :window_with_simple_component do |c|
    c.width = 400
    c.height = 300
    c.title = "Window with nested SimpleComponent"
    c.items = [{klass: SimpleComponent}]
  end

  component :inaccessible do |c|
    c.klass = Netzke::Core::Panel
    c.excluded = true
  end

  component :dynamic_child do |c|
    c.klass = c.client_config[:klass].constantize
  end

  component :self_reloading

  action :non_existing_component do |a|
    a.text = "Non-existing component"
  end

  action :load_with_feedback, :load_component, :load_in_window, :load_window_with_simple_component, :load_with_params, :config_only, :inaccessible, :load_self_reloading, :load_dynamic_child

  def configure(c)
    super
    c.tbar = [:load_component, :load_in_window, :load_with_feedback, :load_window_with_simple_component, :load_with_params]
    c.bbar = [:non_existing_component, :inaccessible, :config_only, :load_self_reloading, :load_dynamic_child]
  end
end
