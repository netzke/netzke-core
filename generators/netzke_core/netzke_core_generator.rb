# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeCoreGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_netzke_preferences.rb', 'db/migrate', :assigns => {
        :migration_name => "CreateNetzkePreferences"
      }, :migration_file_name => "create_netzke_preferences"
    end
  end
end
