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

        if Rails.configuration.cache_classes
          # Memoize Netzke::Base.constantize_class_name for performance
          class << Netzke::Base
            memoize :constantize_class_name
          end
        end

        # Generate dynamic assets and put them into public/netzke
        require 'fileutils'
        FileUtils.mkdir_p(Rails.root.join('public', 'netzke'))

        File.open(Rails.root.join('public', 'netzke', 'ext.js'), 'w') {|f| f.write(Netzke::Core::DynamicAssets.ext_js) }
        File.open(Rails.root.join('public', 'netzke', 'ext.css'), 'w') {|f| f.write(Netzke::Core::DynamicAssets.ext_css) }
        File.open(Rails.root.join('public', 'netzke', 'touch.js'), 'w') {|f| f.write(Netzke::Core::DynamicAssets.touch_js) }
        File.open(Rails.root.join('public', 'netzke', 'touch.css'), 'w') {|f| f.write(Netzke::Core::DynamicAssets.touch_css) }
      end
    end
  end
end