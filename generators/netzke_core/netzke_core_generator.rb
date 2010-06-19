# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeCoreGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_netzke_preferences.rb', 'db/migrate', :assigns => {
        :migration_name => "CreateNetzkePreferences"
      }, :migration_file_name => "create_netzke_preferences"
    end
  end
  
  def self.gem_root
    File.expand_path('../../../', __FILE__)
  end

  def self.source_root
    File.join(gem_root, 'templates', 'core')
  end  
end
