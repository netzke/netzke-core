#
# TODO: would be great to support somethnig like:
# NetzkePreference["name"].merge!({:a => 1, :b => 2}) # if NetzkePreference["name"] returns a hash
# or
# NetzkePreference["name"] << 2 # if NetzkePreference["name"] returns an array
# etc
#
class NetzkePreference < ActiveRecord::Base
  named_scope :for_current_user, lambda { {:conditions => {:user_id => user_id}} }
  
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
    when 'Array', 'Hash' then r = JSON.parse(norm_value)
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
    conditions = {:name => pref_name, :user_id => user_id, :widget_name => self.widget_name}
    pref       = self.find(:first, :conditions => conditions)
    pref && pref.normalized_value
  end
  
  def self.[]=(pref_name, new_value)
    pref_name  = normalize_preference_name(pref_name)
    conditions = {:name => pref_name, :user_id => user_id, :widget_name => self.widget_name}
    pref       = self.find(:first, :conditions => conditions)
    
    # if assigning nil, simply delete the eventually found preference
    if new_value.nil?
      pref && pref.destroy
    else
      pref ||= self.new(conditions)
      pref.normalized_value = new_value
      pref.save!
    end
  end
  
  private
  def self.normalize_preference_name(name)
    name.to_s.gsub(".", "__").gsub("/", "__")
  end
  
end
