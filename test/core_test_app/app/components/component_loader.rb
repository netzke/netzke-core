# TODO: some functionality (one that is calling doNothing) does not belong here, as it loads no componens, but rather to ServerCaller. Move it there.
class ComponentLoader < Netzke::Base
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

  component :some_composite

  # this action is using loadNetzkeComponent "special" callback
  action :load_with_feedback

  # this action is using generic endpoint callback
  action :load_with_generic_callback

  # this action is using generic endpoint callback with scope
  action :load_with_generic_callback_and_scope

  endpoint :do_nothing do |params|
    # here be tumbleweed
#    {}
  end

  action :load_component

  action :load_in_window

  action :load_window_with_simple_component

  action :load_composite

  action :load_with_params

  action :non_existing_component do |a|
    a.text = "Non-existing component"
  end

  def configure(c)
    super
    c.bbar = [:load_component, :load_in_window, :load_with_feedback, :load_window_with_simple_component, :load_composite, :load_with_params, :load_with_generic_callback, :load_with_generic_callback_and_scope, :non_existing_component]
  end

  endpoint :deliver_component do |params, this|
    if params[:name] == "simple_component" && params[:html]
      components[:simple_component].merge!(:html => params[:html])
    end
    super(params, this)
  end
end
