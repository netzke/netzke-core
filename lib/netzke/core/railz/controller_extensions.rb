module Netzke
  module Railz
    # Before each request, Netzke::Base.controller and Netzke::Base.session are set, to be accessible from components.
    module ControllerExtensions
      def self.included(base)
        base.send(:before_filter, :set_controller_and_session)
      end

      protected

      def set_controller_and_session
        Netzke::Base.controller = self
        Netzke::Base.session = session
      end
    end
  end
end
