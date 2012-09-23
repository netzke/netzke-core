module ExtDirect
  class Composite < Netzke::Base
    js_configure do |c|
      c.layout = :border
      c.border = true
      c.init_component = <<-JS
        function(){
          this.callParent();

          this.getChildNetzkeComponent('selector').on('userupdate', function(user){
            this.setUser(user);
            this.getChildNetzkeComponent('details').update();
            this.getChildNetzkeComponent('statistics').update();
          }, this);
        }
      JS
    end

    component :selector do |c|
      c.klass = ExtDirect::Selector # a form that will allow us to select a user
    end

    component :details do |c|
      c.klass = ExtDirect::Details # a panel that will display details for the user
      c.user = component_session[:user]
    end

    component :statistics do |c|
      c.klass = ExtDirect::Statistics # a panel that will display statistics for the user
      c.user = component_session[:user]
    end

    def configure(c)
      super
      c.items = [
        {:region => :north, :height => 100, netzke_component: :selector},
        {:region => :center, netzke_component: :details},
        {:region => :east, :width => 300, :split => true, netzke_component: :statistics}
      ]
    end

    endpoint :set_user do |params, this|
      component_session[:user] = params
    end

  end
end
