module ExtDirect
  class Composite < Netzke::Base
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
