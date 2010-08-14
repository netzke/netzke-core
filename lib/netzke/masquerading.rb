module Netzke
  module Masquerading
    module ClassMethods
      # Example:
      #   masquarade_as(:role, 2)
      #   masquarade_as(:user, 4)
      #   masquarade_as(:world)
      def masquerade_as(authority_level, authority_id = true)
        reset_masquerading
        session.merge!(:"masq_#{authority_level}" => authority_id)
      end
    
      def reset_masquerading
        session[:masq_world] = session[:masq_role] = session[:masq_user] = nil
      end
    
      # Who are we acting as?
      def authority_level
        if session[:masq_world]
          :world
        elsif session[:masq_role]
          [:role, session[:masq_role]]
        elsif session[:masq_user]
          [:user, session[:masq_user]]
        elsif session[:netzke_user_id]
          [:self, session[:netzke_user_id]]
        else
          :none # or nil ?
        end
      end

      
    end
    
    module InstanceMethods
      
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end