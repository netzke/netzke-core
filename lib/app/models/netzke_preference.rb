class NetzkePreference < ActiveRecord::Base
  CONVERTION_METHODS= {'Fixnum' => 'to_i', 'String' => 'to_s', 'Float' => 'to_f', 'Symbol' => 'to_sym'}

  def self.user=(user)
    @@user = user
  end
  
  def self.user
    @@user ||= nil
  end
  
  def self.custom_field=(value)
    @@custom_field = value
  end
  
  def self.custom_field
    @@custom_field ||= nil
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
    elsif klass == 'Array'
      r = JSON.parse(norm_value)
    else
      r = norm_value.send(CONVERTION_METHODS[klass])
    end
    r
  end
  
  def normalized_value=(new_value)
    # norm_value = (new_value.to_s if new_value == true or new_value == false) || new_value
    case new_value.class.to_s
    when "Array"
      write_attribute(:value, new_value.to_json)
    else
      write_attribute(:value, new_value.to_s)
    end
    write_attribute(:pref_type, [TrueClass, FalseClass].include?(new_value.class) ? 'Boolean' : new_value.class.to_s)
  end
  
  def self.[](pref_name)
    pref_name = pref_name.to_s
    conditions = {:name => pref_name, :user_id => self.user, :custom_field => self.custom_field}
    pref = self.find(:first, :conditions => conditions)
    # pref = @@user.nil? ? self.find_by_name(pref_name) : self.find_by_name_and_user_id(pref_name, @@user.id)
    pref && pref.normalized_value
  end
  
  def self.[]=(pref_name, new_value)
    pref_name = pref_name.to_s
    conditions = {:name => pref_name, :user_id => self.user, :custom_field => self.custom_field}
    pref = self.find(:first, :conditions => conditions) || self.create(conditions)
    # pref = self.user.nil? ? self.find_or_create_by_name(pref_name) : self.find_or_create_by_name_and_user_id(pref_name, self.user.id)
    pref.normalized_value = new_value
    pref.save!
  end
  
end
