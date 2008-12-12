# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeCoreGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "public/javascripts/netzke"
      m.file 'netzke.js', "public/javascripts/netzke/netzke.js"
      m.migration_template 'create_netzke_preferences.rb', "db/migrate", {:migration_file_name => "create_netzke_preferences"}
    end
  end
end
