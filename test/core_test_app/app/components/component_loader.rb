# TODO: some functionality (one that is calling doNothing) does not belong here, as it loads no componens, but rather to ServerCaller. Move it there.
class ComponentLoader < Netzke::Base
  component :simple_component, :title => "Simple Component", :lazy_loading => true

  component :component_loaded_in_window, {
    :class_name => "SimpleComponent",
    :title => "Component loaded in window",
    :lazy_loading => true
  }

  component :window_with_simple_component, {
    :class_name => "SimpleWindow",
    :width => 400,
    :height => 300,
    :items => [{
      :class_name => "SimpleComponent",
      :title => "Simple Component Inside Window"
    }],
    :lazy_loading => true
  }

  component :some_composite, :lazy_loading => true

  # this action is using loadNetzkeComponent "special" callback
  js_method :on_load_with_feedback, <<-JS
    function(){
      this.loadNetzkeComponent({name: 'simple_component', callback: function(){
        this.setTitle("Callback" + " invoked!");
      }, scope: this});
    }
  JS

  # this action is using generic endpoint callback
  action :load_with_generic_callback
  js_method :on_load_with_generic_callback, <<-JS
    function(){
      this.doNothing({}, function () {
        this.setTitle("Generic callback invoked!");
      });
    }
  JS

  # this action is using generic endpoint callback with scope
  action :load_with_generic_callback_and_scope
  js_method :on_load_with_generic_callback_and_scope, <<-JS
    function(){
      var that=this;
      var fancyScope={
        setFancyTitle: function () {
          that.setTitle("Fancy title set!");
        }
      };
      this.doNothing({}, function () {
        this.setFancyTitle();
      }, fancyScope);
    }
  JS

  endpoint :do_nothing do |params|
    # here be tumbleweed
#    {}
  end

  action :load_component

  action :load_in_window

  action :load_with_feedback

  action :load_window_with_simple_component

  action :load_composite

  action :load_with_params

  action :non_existing_component do |a|
    a.text = "Non-existing component"
  end

  js_properties(
    :title => "Component Loader",
    :layout => "fit",
    :bbar => [:load_component.action, :load_in_window.action, :load_with_feedback.action, :load_window_with_simple_component.action, :load_composite.action, :load_with_params.action, :load_with_generic_callback.action, :load_with_generic_callback_and_scope.action, :non_existing_component.action]
  )

  js_method :on_load_window_with_simple_component, <<-JS
    function(params){
      this.loadNetzkeComponent({name: "window_with_simple_component", callback: function(w){
        w.show();
      }});
    }
  JS

  js_method :on_load_composite, <<-JS
    function(params){
      this.loadNetzkeComponent({name: "some_composite", container: this});
    }
  JS

  js_method :on_load_with_params, <<-JS
    function(params){
      this.loadNetzkeComponent({name: "simple_component", params: {html: "Simple Component" + " with changed HTML"}, container: this});
    }
  JS

  js_method :on_load_component, <<-JS
    function(){
      this.loadNetzkeComponent({name: 'simple_component', container: this});
    }
  JS

  js_method :on_non_existing_component, <<-JS
    function(){
      this.loadNetzkeComponent({name: 'non_existing_component', container: this});
    }
  JS

  js_method :on_load_in_window, <<-JS
    function(){
      var w = new Ext.window.Window({
        width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
      });
      w.show();
      this.loadNetzkeComponent({name: 'component_loaded_in_window', container: w});
    }
  JS

  def deliver_component_endpoint(params)
    if params[:name] == "simple_component" && params[:html]
      components[:simple_component].merge!(:html => params[:html])
    end
    super
  end

  # For visual testing purposes
  # def deliver_component_endpoint(params)
  #   sleep 2
  #   super
  # end

end
