# TODO: some functionality (one that is calling doNothing) does not belong here, as it loads no componens, but rather to ServerCaller. Move it there.
class ComponentLoader < Netzke::Base
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

  def configure
    super
    config.bbar = [:load_component, :load_in_window, :load_with_feedback, :load_window_with_simple_component, :load_composite, :load_with_params, :load_with_generic_callback, :load_with_generic_callback_and_scope, :non_existing_component]
  end

  js_properties(
    :title => "Component Loader",
    :layout => "fit"
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

  endpoint :deliver_component do |params, this|
    if params[:name] == "simple_component" && params[:html]
      components[:simple_component].merge!(:html => params[:html])
    end
    super(params, this)
  end

end
