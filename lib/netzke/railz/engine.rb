module Netzke
  module Railz
    class Engine < Rails::Engine
      config.netzke = Netzke::Core::OptionsHash.new

      # before loading initializers and classes (in app/**)
      config.before_initialize do
        Netzke::Core.config = config.netzke
        Netzke::Core.ext_location = Rails.root.join("public", "extjs")
        Netzke::Core.touch_location = Rails.root.join("public", "sencha-touch")
        Netzke::Core.persistence_manager_class = Netzke::Core.persistence_manager.constantize rescue nil
      end

      # after loading initializers and classes
      config.after_initialize do
        Netzke::Core.with_icons = File.exists?("#{::Rails.root}/public#{Netzke::Core.icons_uri}") if Netzke::Core.with_icons.nil?

        # If need to cache classes, memoize Netzke::Base.constantize_class_name for performance
        if Rails.configuration.cache_classes
          class << Netzke::Base
            memoize :constantize_class_name
          end
        end
      end
    end
  end
end