module Netzke
  class KindaComplexComponent < Component::Base
    # Note the use of ActiveSupport::Concern module
    module BasicStuff
      extend ActiveSupport::Concern
      
      included do
        # Calling main class' methods is simple
        js_method :on_some_action, <<-JS
          function(){ this.items.last().setTitle("Action triggered"); }
        JS
    
        js_properties(
          :active_tab => 0, :bbar => [:some_action.ext_action]
        )
      end

      # Instance method, overridden in the ExtraStuff module
      def config
        {
          :items => [{:title => "Panel One"}, {:title => "Panel Two"}]
        }.deep_merge super
      end
      
    end
  end
end