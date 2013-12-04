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
        if Netzke::Core.with_icons.nil?
          icon_folder_exists = File.exists?("#{::Rails.root}/public#{Netzke::Core.icons_uri}")
          unless icon_folder_exists && Netzke::Core.icons_uri =~ /^assets/
            assets_icons_path = File.join("assets", "images", Netzke::Core.icons_uri[7..-1])
            icon_folder_exists =
              File.exists?(File.join(Rails.root, assets_icons_path)) ||
              File.exists?(File.join(Rails.root, "lib", assets_icons_path)) ||
              File.exists?(File.join(Rails.root, "vendor", assets_icons_path))
          end
          Netzke::Core.with_icons = icon_folder_exists
        end
      end
    end
  end
end
