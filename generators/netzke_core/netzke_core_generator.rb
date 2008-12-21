# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeCoreGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "public/javascripts/netzke"
      m.file 'netzke.js', "public/javascripts/netzke/netzke.js"
      m.file 'netzke.html.erb', "app/views/layouts/netzke.html.erb"
      m.migration_template 'create_netzke_preferences.rb', "db/migrate", {:migration_file_name => "create_netzke_preferences"}
      # FIXME: how do we avoid getting the same migration IDs?
      m.migration_template 'create_netzke_layouts.rb', "db/migrate", {:migration_file_name => "create_netzke_layouts"}
    end
  end
end
