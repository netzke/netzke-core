module Netzke
  module Railz
    module ControllerExtensions
      def self.included(base)
        base.send(:before_filter, :set_session_data)
        base.send(:before_filter, :set_controller)
      end

      def set_session_data
        Netzke::Base.session = session
      end

      def set_controller
        Netzke::Base.controller = self
      end
    end
  end
end
