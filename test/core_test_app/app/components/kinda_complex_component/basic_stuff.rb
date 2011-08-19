class KindaComplexComponent < Netzke::Base
  # Note the use of ActiveSupport::Concern module
  module BasicStuff
    extend ActiveSupport::Concern

    included do
      action :some_action
      action :another_action

      # Calling main class' methods is simple
      js_method :on_some_action, <<-JS
        function(){ this.items.last().setTitle("Action triggered"); }
      JS

      # Another way of defining a JS method
      js_method :on_another_action do
        <<-JS
          function(){ this.items.first().setTitle("Another action triggered"); }
        JS
      end

      js_properties(
        :active_tab => 0, :bbar => [:some_action.action, :another_action.action]
      )

      # Instance method, overridden in the ExtraStuff module
      # config
    end

    def final_config
      super.merge(:items => [{:title => "Panel One"}, {:title => "Panel Two"}])
    end

  end
end