# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeCoreGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # FIXME: how do we avoid getting the same migration timestamps?
      # Work-around
      time = Time.now.utc.strftime("%Y%m%d%H%M%S")
      m.directory 'db/migrate'
      # m.file 'create_netzke_layouts.rb', "db/migrate/#{time}_create_netzke_layouts.rb"
      m.file 'create_netzke_preferences.rb', "db/migrate/#{time.to_i+1}_create_netzke_preferences.rb"
    end
  end
end
