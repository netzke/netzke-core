module ActionDispatch::Routing
  # class RouteSet #:nodoc:
  #   # Ensure Devise modules are included only after loading routes, because we
  #   # need devise_for mappings already declared to create filters and helpers.
  #   def finalize_with_devise!
  #     finalize_without_devise!
  #     Devise.configure_warden!
  #     ActionController::Base.send :include, Devise::Controllers::Helpers
  #   end
  #   alias_method_chain :finalize!, :devise
  # end

  class Mapper
    # Includes netzke_for method for routes. This method is responsible to
    # generate all needed routes for netzke, based on what modules you have
    # defined in your model.
    #
    #   netzke_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    def netzke
      puts "Routing netzke"
      
      # options = resources.extract_options!
      # resources.map!(&:to_sym)
      # 
      # resources.each do |resource|
      #   mapping = Devise.register(resource, options)
      # 
      #   unless mapping.to.respond_to?(:devise)
      #     raise "#{mapping.to.name} does not respond to 'devise' method. This usually means you haven't " <<
      #       "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'devise/orm/YOUR_ORM' " <<
      #       "inside 'config/initializers/devise.rb' or before your application definition in 'config/application.rb'"
      #   end
      # 
      #   routes  = mapping.routes
      #   routes -= Array(options.delete(:skip)).map { |s| s.to_s.singularize.to_sym }
      # 
      #   routes.each do |mod|
      #     send(:"devise_#{mod}", mapping, mapping.controllers)
      #   end
      # end
    end
  end
end