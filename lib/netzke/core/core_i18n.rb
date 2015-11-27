module Netzke
  module Core
    module CoreI18n
      extend ActiveSupport::Concern
      module ClassMethods
        # The ID used to locate this component's block in locale files
        def i18n_id
          name.split("::").map{|c| c.underscore}.join(".")
        end
      end

      def i18n_id
        self.class.i18n_id
      end
    end
  end
end
