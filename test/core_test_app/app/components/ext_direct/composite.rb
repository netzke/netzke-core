module ExtDirect
  class Composite < Netzke::Base
    js_property :layout, :border
    js_property :border, true

    component :selector, :class_name => "ExtDirect::Selector" # a form that will allow us to select a user

    component :details do
      {
        :class_name => "ExtDirect::Details", # a panel that will display details for the user
        :user => component_session[:user]
      }
    end

    component :statistics do
      {
        :class_name => "ExtDirect::Statistics", # a panel that will display details for the user
        :user => component_session[:user]
      }
    end

    def configuration
      super.merge({
        :items => [:selector.component(:region => :north, :height => 100),
          :details.component(:region => :center),
          :statistics.component(:region => :east, :width => 300, :split => true)
        ]
      })
    end

    endpoint :set_user do |params|
      component_session[:user] = params
    end

    js_method :init_component, <<-JS
      function(){
        Netzke.classes.ExtDirect.Composite.superclass.initComponent.call(this);

        this.getChildComponent('selector').on('userupdate', function(user){
          this.setUser(user);
          this.getChildComponent('details').update();
          this.getChildComponent('statistics').update();
        }, this);
      }
    JS

  end
end
