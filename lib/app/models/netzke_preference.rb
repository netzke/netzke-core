#
# TODO: would be great to support somethnig like:
# NetzkePreference["name"].merge!({:a => 1, :b => 2}) # if NetzkePreference["name"] returns a hash
# or
# NetzkePreference["name"] << 2 # if NetzkePreference["name"] returns an array
# etc
#
class NetzkePreference < ActiveRecord::Base
  # named_scope :for_current_user, lambda { {:conditions => {:user_id => user_id}} }
  
  ELEMENTARY_CONVERTION_METHODS= {'Fixnum' => 'to_i', 'String' => 'to_s', 'Float' => 'to_f', 'Symbol' => 'to_sym'}
  
  def self.user_id
    Netzke::Base.user && Netzke::Base.user.id
  end
  
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
      pref ||= self.new(conditions(pref_name))
      pref.normalized_value = new_value
      pref.save!
    end
  end
  
  # Override this method if you want a different strategy of finding the correct preference, based on your
  # authorization strategy
  def self.pref_to_read(name)
    session = Netzke::Base.session
    cond = {:name => name, :widget_name => self.widget_name}
    
    if session[:masq_user] || session[:masq_role]
      cond.merge!({:user_id => session[:masq_user].try(:id), :role_id => session[:masq_role].try(:id)})
      res = self.find(:first, :conditions => cond)
    elsif session[:user]
      res = self.find(:first, :conditions => cond.merge({:user_id => session[:user].id}))
      res ||= self.find(:first, :conditions => cond.merge({:role_id => session[:user].role.id}))
    end
    
    res      
  end
  
  def self.pref_to_write(name)
    self.new
  end
  # def self.conditions(pref_name)
  #   cond = {:name => pref_name, :widget_name => self.widget_name}
  #   
  #   
  #   if session[:masq_user]
  #     cond.merge!({:user_id => session[:masq_user].id})
  #   elsif session[:masq_role]
  #     cond.merge!({:role_id => session[:masq_role].id})
  #   end
  # 
  #   cond
  # end
  
  private
  def self.normalize_preference_name(name)
    name.to_s.gsub(".", "__").gsub("/", "__")
  end
  
end
