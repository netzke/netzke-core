module Netzke
  module Railz
    class Engine < Rails::Engine
      # config.netzke = Netzke::Core::OptionsHash.new

      initializer "netzke.core" do |app|
        app.config.eager_load_paths -= ["#{app.config.root}/app/components"]
        app.config.autoload_paths += ["#{app.config.root}/app/components"]
      end

      # before loading initializers
      config.before_initialize do |app|
        # Netzke::Core.config = config.netzke # passing app-level config to Netzke::Core
        Netzke::Core.persistence_manager_class = Netzke::Core.persistence_manager.constantize rescue nil
      end

      # after loading initializers
      config.after_initialize do
        Netzke::Core.ext_path = Rails.root.join('public', Netzke::Core.ext_uri[1..-1])
        Netzke::Core.with_icons = File.exists?("#{::Rails.root}/public#{Netzke::Core.icons_uri}") if Netzke::Core.with_icons.nil?

        # Dynamic generation of Netzke js and css.
        # WIP: the problem with this is that on Heroku, for example, you don't have write access to 'public'.
        # dynamic_assets = %w[ext.js ext.css touch.js touch.css]
        #
        # if Rails.configuration.cache_classes
        #   # Memoize Netzke::Base.constantize_class_name for performance
        #   class << Netzke::Base
        #     memoize :constantize_class_name
        #   end
        #
        #   # Generate dynamic assets and put them into public/netzke
        #   require 'fileutils'
        #   FileUtils.mkdir_p(Rails.root.join('public', 'netzke'))
        #
        #   dynamic_assets.each do |asset|
        #     File.open(Rails.root.join('public', 'netzke', asset), 'w') {|f| f.write(Netzke::Core::DynamicAssets.send(asset.sub(".", "_"))) }
        #   end
        # else
        #   dynamic_assets.each do |asset|
        #     file_path = Rails.root.join('public', 'netzke', asset)
        #     File.delete(file_path) if File.exists?(file_path)
        #   end
        # end
      end
    end
  end
end
