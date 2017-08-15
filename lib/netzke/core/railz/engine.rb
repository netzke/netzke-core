module Netzke
  module Railz
    class Engine < Rails::Engine
      initializer "netzke.core" do |app|
        # app.config.eager_load_paths += ["#{app.config.root}/app/components"]
      end

      # before loading initializers
      config.before_initialize do |app|
        Netzke::Core.ext_path = Rails.root.join('public', Netzke::Core.ext_uri[1..-1])
      end

      config.after_initialize do |app|
        if Netzke::Core.with_icons.nil?
          Netzke::Core.with_icons = File.exists?("#{::Rails.root}/public#{Netzke::Core.icons_uri}")
        end
      end
    end
  end
end
