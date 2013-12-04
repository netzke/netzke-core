module Netzke
  module Railz
    class Engine < Rails::Engine
      initializer "netzke.core" do |app|
        app.config.eager_load_paths -= ["#{app.config.root}/app/components"]
        app.config.autoload_paths += ["#{app.config.root}/app/components"]
      end

      # before loading initializers
      config.before_initialize do |app|
        Netzke::Core.ext_path = Rails.root.join('public', Netzke::Core.ext_uri[1..-1])
      end

      config.after_initialize do |app|
        Netzke::Core.with_icons = !!Rails.application.assets.find_asset("icons/accept.png") if Netzke::Core.with_icons.nil?
      end
    end
  end
end
