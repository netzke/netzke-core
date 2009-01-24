# TODO: would be great to support somethnig like:
# NetzkePreference["name"].merge!({:a => 1, :b => 2}) # if NetzkePreference["name"] returns a hash
# or
# NetzkePreference["name"] << 2 # if NetzkePreference["name"] returns an array
# etc
#
class NetzkePreference < ActiveRecord::Base
  ELEMENTARY_CONVERTION_METHODS= {'Fixnum' => 'to_i', 'String' => 'to_s', 'Float' => 'to_f', 'Symbol' => 'to_sym'}
  
  # Multi user support
  def self.user
    @@user ||= nil
  end
  
  def self.user=(user)
    @@user = user
  end
  
  def self.user_id
    user && user.id
  end
  
  def self.widget_name=(value)
    @@widget_name = value
  end
  
  def self.widget_name
    @@widget_name ||= nil
  end
  
  def normalized_value
    klass = read_attribute(:pref_type)
    norm_value = read_attribute(:value)
    if klass.nil?
      # do not cast
      r = norm_value
    elsif klass == 'Boolean'
      r = norm_value == 'false' ? false : (norm_value == 'true' || norm_value)
    elsif klass == 'NilClass'
      r = nil
    elsif klass == 'Array' || klass == 'Hash'
      r = JSON.parse(norm_value)
    else
      r = norm_value.send(ELEMENTARY_CONVERTION_METHODS[klass])
    end
    r
  end
  
  def normalized_value=(new_value)
    # norm_value = (new_value.to_s if new_value == true or new_value == false) || new_value
    case new_value.class.name
    when "Array"
      write_attribute(:value, new_value.to_json)
    when "Hash"
      write_attribute(:value, new_value.to_json)
    else
      write_attribute(:value, new_value.to_s)
    end
    write_attribute(:pref_type, [TrueClass, FalseClass].include?(new_value.class) ? 'Boolean' : new_value.class.to_s)
  end
  
  def self.[](pref_name)
    pref_name = pref_name.to_s
    conditions = {:name => pref_name, :user_id => user_id, :widget_name => self.widget_name}
    pref = self.find(:first, :conditions => conditions)
    # pref = @@user.nil? ? self.find_by_name(pref_name) : self.find_by_name_and_user_id(pref_name, @@user.id)
    pref && pref.normalized_value
  end
  
  def self.[]=(pref_name, new_value)
    pref_name = pref_name.to_s
    conditions = {:name => pref_name, :user_id => user_id, :widget_name => self.widget_name}
    pref = self.find(:first, :conditions => conditions)
    
    # if assigning nil, simply delete the eventually found preference
    if new_value.nil?
      pref && pref.destroy
    else
      pref ||= self.new(conditions)
      pref.normalized_value = new_value
      pref.save!
    end
  end
  
end
