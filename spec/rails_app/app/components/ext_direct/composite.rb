module ExtDirect
  class Composite < Netzke::Base
    client_class do |c|
      c.layout = :border
      c.border = true
      c.init_component = <<-JS
        function(){
          this.callParent();

          Ext.Ajax.on('beforerequest',function (conn, options ) {
            Netzke.connectionCount = Netzke.connectionCount || 0;
            Netzke.connectionCount++;
          });

          this.nzGetComponent('selector').on('userupdate', function(user){
            this.setUser(user);
            this.nzGetComponent('details').update();
            this.nzGetComponent('statistics').update();
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
        {:region => :north, :height => 100, component: :selector},
        {:region => :center, component: :details},
        {:region => :east, :width => 300, :split => true, component: :statistics}
      ]
    end

    endpoint :set_user do |user|
      component_session[:user] = user
    end
  end
end
