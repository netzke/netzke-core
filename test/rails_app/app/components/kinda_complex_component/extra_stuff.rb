class KindaComplexComponent < Netzke::Base
  module ExtraStuff
    extend ActiveSupport::Concern
    
    included do
      component :server_caller
    end
    
    # Let's add another tab with a Netzke component in it
    def final_config
      orig = super
      orig[:items] << js_component(:server_caller)
      orig
    end
  end
end