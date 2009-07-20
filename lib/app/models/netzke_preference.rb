#
# TODO: would be great to support something like this:
# NetzkePreference["name"].merge!({:a => 1, :b => 2}) # if NetzkePreference["name"] returns a hash
# or
# NetzkePreference["name"] << 2 # if NetzkePreference["name"] returns an array
# etc
#
class NetzkePreference < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  ELEMENTARY_CONVERTION_METHODS= {'Fixnum' => 'to_i', 'String' => 'to_s', 'Float' => 'to_f', 'Symbol' => 'to_sym'}
  
  # def self.user_id
  #   Netzke::Base.user && Netzke::Base.user.id
  # end
  
  def self.widget_name=(value)
    @@widget_name = value
  end
  
  def self.widget_name
    @@widget_name ||= nil
  end
  
  def normalized_value
    klass      = read_attribute(:pref_type)
    norm_value = read_attribute(:value)
    
    case klass
    when nil             then r = norm_value  # do not cast
    when 'Boolean'       then r = norm_value == 'false' ? false : (norm_value == 'true' || norm_value)
    when 'NilClass'      then r = nil
    when 'Array', 'Hash' then r = ActiveSupport::JSON.decode(norm_value)
    else
      r = norm_value.send(ELEMENTARY_CONVERTION_METHODS[klass])
    end
    r
  end
  
  def normalized_value=(new_value)
    case new_value.class.name
    when "Array" then write_attribute(:value, new_value.to_json)
    when "Hash"  then write_attribute(:value, new_value.to_json)
    else              write_attribute(:value, new_value.to_s)
    end
    write_attribute(:pref_type, [TrueClass, FalseClass].include?(new_value.class) ? 'Boolean' : new_value.class.to_s)
  end
  
  def self.[](pref_name)
    pref_name  = normalize_preference_name(pref_name)
    pref       = self.pref_to_read(pref_name)
    pref && pref.normalized_value
  end
  
  def self.[]=(pref_name, new_value)
    pref_name  = normalize_preference_name(pref_name)
    pref       = self.pref_to_write(pref_name)
    
    # if assigning nil, simply delete the eventually found preference
    if new_value.nil?
      pref && pref.destroy
    else
      # pref ||= self.new(conditions(pref_name))
      pref.normalized_value = new_value
      pref.save!
    end
  end

  # Overwrite pref_to_read, pref_to_write methods, and find_all_for_widget if you want a different way of 
  # identifying the proper preference based on your own authorization strategy.
  #
  # The default strategy is:
  #   1) if no masq_user or masq_role defined
  #     pref_to_read will search for the preference for user first, then for user's role
  #     pref_to_write will always find or create a preference for the current user (never for its role)
  #   2) if masq_user or masq_role is defined
  #     pref_to_read and pref_to_write will always take the masquerade into account, e.g. reads/writes will go to
  #     the user/role specified
  #   
  def self.pref_to_read(name)
    name = name.to_s
    session = Netzke::Base.session
    cond = {:name => name, :widget_name => self.widget_name}
    
    if session[:masq_user]
      # first, get the prefs for this user it they exist
      res = self.find(:first, :conditions => cond.merge({:user_id => session[:masq_user]}))
      # if it doesn't exist, get them for the user's role
      user = User.find(session[:masq_user])
      res ||= self.find(:first, :conditions => cond.merge({:role_id => user.role.id}))
    elsif session[:masq_role]
      res = self.find(:first, :conditions => cond.merge({:role_id => session[:masq_role]}))
    elsif session[:netzke_user_id]
      user = User.find(session[:netzke_user_id])
      res = self.find(:first, :conditions => cond.merge({:user_id => user.id}))
      res ||= self.find(:first, :conditions => cond.merge({:role_id => user.role.id}))
    else
      res = self.find(:first, :conditions => cond)
    end
    
    res      
  end
  
  def self.pref_to_write(name)
    name = name.to_s
    session = Netzke::Base.session
    cond = {:name => name, :widget_name => self.widget_name}
    
    if session[:masq_user]
      cond.merge!({:user_id => session[:masq_user]})
      res = self.find(:first, :conditions => cond)
      res ||= self.new(cond)
    elsif session[:masq_role]
      # first, delete all the corresponding preferences for the users that have this role
      Role.find(session[:masq_role]).users.each do |u|
        self.delete_all(cond.merge({:user_id => u.id}))
      end
      cond.merge!({:role_id => session[:masq_role]})
      res = self.find(:first, :conditions => cond)
      res ||= self.new(cond)
    elsif session[:netzke_user_id]
      res = self.find(:first, :conditions => cond.merge({:user_id => session[:netzke_user_id]}))
      res ||= self.new(cond.merge({:user_id => session[:netzke_user_id]}))
    else
      res = self.find(:first, :conditions => cond)
      res ||= self.new(cond)
    end
    res
  end
  
  def self.find_all_for_widget(name)
    session = Netzke::Base.session
    cond = {:widget_name => name}
    
    if session[:masq_user] || session[:masq_role]
      cond.merge!({:user_id => session[:masq_user], :role_id => session[:masq_role]})
      res = self.find(:all, :conditions => cond)
    elsif session[:netzke_user_id]
      user = User.find(session[:netzke_user_id])
      res = self.find(:all, :conditions => cond.merge({:user_id => session[:netzke_user_id]}))
      res += self.find(:all, :conditions => cond.merge({:role_id => user.role.try(:id)}))
    else
      res = self.find(:all, :conditions => cond)
    end
    
    res      
  end
  
  private
  def self.normalize_preference_name(name)
    name.to_s.gsub(".", "__").gsub("/", "__")
  end
  
end
