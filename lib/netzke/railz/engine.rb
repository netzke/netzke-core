module Netzke
  module Railz
    class Engine < Rails::Engine
      config.netzke = Netzke::Core::OptionsHash.new

      # before loading initializers and classes (in app/**)
      config.before_initialize do
        Netzke::Core.config = config.netzke
        Netzke::Core.persistence_manager_class = Netzke::Core.persistence_manager.constantize rescue nil
        Netzke::Core.ext_path = Rails.root.join('public', Netzke::Core.ext_uri[1..-1])
      end

      # after loading initializers and classes
      config.after_initialize do
        Netzke::Core.with_icons = File.exists?("#{::Rails.root}/public#{Netzke::Core.icons_uri}") if Netzke::Core.with_icons.nil?

        dynamic_assets = %w[ext.js ext.css touch.js touch.css]

        if Rails.configuration.cache_classes
          # Memoize Netzke::Base.constantize_class_name for performance
          class << Netzke::Base
            memoize :constantize_class_name
          end

          # Generate dynamic assets and put them into public/netzke
          require 'fileutils'
          FileUtils.mkdir_p(Rails.root.join('public', 'netzke'))

          dynamic_assets.each do |asset|
            File.open(Rails.root.join('public', 'netzke', asset), 'w') {|f| f.write(Netzke::Core::DynamicAssets.send(asset.sub(".", "_"))) }
          end
        else
          dynamic_assets.each do |asset|
            file_path = Rails.root.join('public', 'netzke', asset)
            File.delete(file_path) if File.exists?(file_path)
          end
        end

      end
    end
  end
end
