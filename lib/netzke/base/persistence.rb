module Netzke
  class Base
    # TODO: 
    # rename persistence_ to persistence_
    module Persistence
      
      module ClassMethods
        # Persistent config manager class
        def persistence_manager_class
          Netzke::Base.config[:persistence_manager].try(:constantize)
        rescue NameError
          nil
        end

      end
    
      module InstanceMethods
        
        # If the component has persistent config in its disposal
        def persistence_enabled?
          !persistence_manager_class.nil? && initial_config[:persistent_config]
        end
        
        # Access to own persistent config, e.g.:
        #     persistent_config["window.size"] = 100
        #     persistent_config["window.size"] => 100
        # This method is user/role-aware
        # def persistent_config
        #   if persistence_enabled?
        #     config_class = self.class.persistence_manager_class
        #     config_class.component_name = persistence_key.to_s # pass to the config class our unique name
        #     config_class
        #   else
        #     # if we can't use presistent config, all the calls to it will always return nil, 
        #     # and the "="-operation will be ignored
        #     logger.debug "==> NETZKE: no persistent config is set up for component '#{global_id}'"
        #     {}
        #   end
        # end

        # Access to the global persistent config (e.g. of another component)
        def global_persistent_config(owner = nil)
          config_class = self.class.persistence_manager_class
          config_class.component_name = owner
          config_class
        end

        # A string which will identify NetzkePreference records for this component. 
        # If <tt>persistence_key</tt> is passed, use it. Otherwise use global component's id.
        def persistence_key #:nodoc:
          # initial_config[:persistence_key] ? parent.try(:persistence_key) ? "#{parent.persistence_key}__#{initial_config[:persistence_key]}".to_sym : initial_config[:persistence_key] : global_id.to_sym
          initial_config[:persistence_key] ? initial_config[:persistence_key] : global_id.to_sym
        end

        # def update_persistent_ext_config(hsh)
        #   current_config = persistent_config[:ext_config] || {}
        #   current_config.deep_merge!(hsh.deep_convert_keys{ |k| k.to_s }) # first, recursively stringify the keys
        #   persistent_config[:ext_config] = current_config
        # end
        
        # Returns a hash built from all persistent config values for the current component, following the double underscore
        # naming convention. E.g., if we have the following persistent config pairs:
        #     enabled  => true
        #     layout__width => 100
        #     layout__header__height => 20
        # 
        # this method will return the following hash:
        #     {:enabled => true, :layout => {:width => 100, :header => {:height => 20}}}
        # def persistence_hash_OLD
        #   return {} if !persistence_enabled?
        #   
        #   @persistence_hash ||= begin
        #     prefs = NetzkePreference.find_all_for_component(persistence_key.to_s)
        #     res = {}
        #     prefs.each do |p|
        #       hsh_levels = p.name.split("__").map(&:to_sym)
        #       tmp_res = {} # it decends into itself, building itself
        #       anchor = {} # it will keep the tail of tmp_res
        #       hsh_levels.each do |level_prefix|
        #         tmp_res[level_prefix] ||= level_prefix == hsh_levels.last ? p.normalized_value : {}
        #         anchor = tmp_res[level_prefix] if level_prefix == hsh_levels.first
        #         tmp_res = tmp_res[level_prefix]
        #       end
        #       # Now 'anchor' is a hash that represents the path to the single value, 
        #       # for example: {:ext_config => {:title => 100}} (which corresponds to ext_config__title)
        #       # So we need to recursively merge it into the final result
        #       res.deep_merge!(hsh_levels.first => anchor)
        #     end
        #     res.deep_convert_keys{ |k| k.to_sym } # recursively symbolize the keys
        #   end
        # end
        
        def update_persistent_options(hash)
          if persistence_enabled?
            options = persistent_options
            persistence_manager_class.pref_to_write(global_id).update_attribute(:value, options.deep_merge(hash))
          else
            logger && logger.debug("Netzke warning: No persistence enabled for component '#{global_id}'")
          end
        end
        
        def persistent_options
          return {} if !persistence_enabled?
          persistence_manager_class.pref_to_read(global_id).try(:value) || {}
        end
        
        # A convenience method for instances
        def persistence_manager_class
          self.class.persistence_manager_class
        end
        
      end
    
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end