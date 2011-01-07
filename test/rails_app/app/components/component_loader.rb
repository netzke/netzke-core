class ComponentLoader < Netzke::Base
  component :simple_component, :title => "Simple Component", :lazy_loading => true

  component :component_loaded_in_window, {
    :class_name => "SimpleComponent",
    :title => "Component loaded in window",
    :lazy_loading => true
  }

  component :window_with_simple_component, {
    :class_name => "SimpleWindow",
    :items => [{
      :class_name => "SimpleComponent",
      :title => "Simple Component Inside Window"
    }],
    :lazy_loading => true
  }

  component :some_composite, :lazy_loading => true

  js_method :on_load_with_feedback, <<-JS
    function(){
      this.loadComponent({name: 'simple_component', callback: function(){
        this.setTitle("Callback" + " invoked!");
      }, scope: this});
    }
  JS

  action :load_with_feedback

  action :load_window_with_simple_component

  action :load_composite

  action :load_with_params

  js_properties(
    :title => "Component Loader",
    :layout => "fit",
    :bbar => [{:text => "Load component", :ref => "../button"}, {:text => "Load in window", :ref => "../loadInWindowButton"}, :load_with_feedback.action, :load_window_with_simple_component.action, :load_composite.action, :load_with_params.action]
  )

  js_method :on_load_window_with_simple_component, <<-JS
    function(params){
      this.loadComponent({name: "window_with_simple_component"});
    }
  JS

  js_method :on_load_composite, <<-JS
    function(params){
      this.loadComponent({name: "some_composite"});
    }
  JS

  js_method :on_load_with_params, <<-JS
    function(params){
      this.loadComponent({name: "simple_component", params: {html: "Simple Component with changed HTML"}});
    }
  JS

  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);

      this.button.on('click', function(){
        this.loadComponent({name: 'simple_component', container: this.getId()});
      }, this);

      this.loadInWindowButton.on('click', function(){
        var w = new Ext.Window({
          width: 500, height: 400, modal: true, layout:'fit',
          items: [{xtype: 'panel'}]
        });
        w.show(null, function(){
          this.loadComponent({name: 'component_loaded_in_window', container: w.items.first().getId()});
        }, this);
      }, this);
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
