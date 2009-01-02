# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeCoreGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # m.directory "public/javascripts/netzke"
      # m.file 'netzke.js', "public/javascripts/netzke/netzke.js"
      m.file 'netzke.html.erb', "app/views/layouts/netzke.html.erb"

      # FIXME: how do we avoid getting the same migration IDs?
      # m.migration_template 'create_netzke_preferences.rb', "db/migrate", {:migration_file_name => "create_netzke_preferences"}
      # m.migration_template 'create_netzke_layouts.rb', "db/migrate", {:migration_file_name => "create_netzke_layouts"}

      # Work-around for now
      time = Time.now.utc.strftime("%Y%m%d%H%M%S")
      m.file 'create_netzke_layouts.rb', "db/migrate/#{time}_create_netzke_layouts"
      m.file 'create_netzke_preferences.rb', "db/migrate/#{time.to_i+1}_create_netzke_preferences"
    end
  end
end
