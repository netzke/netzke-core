class Class

  def read_inheritable_attribute(attr)
    a = "__#{attr}".to_sym
    puts "#{self} is reading attribute #{attr}"
    unless self.respond_to?(a)
      self.class_eval <<-RUBY
	class_attribute :#{a}
      RUBY
    end
    self.send(a)
  end

  def write_inheritable_attribute(attr, value)
    puts "#{self} is writing #{attr} with #{value}"
    a = "__#{attr}".to_sym
    unless self.respond_to?(a)
      self.class_eval <<-RUBY
	class_attribute :#{a}
      RUBY
    end
    self.send("#{a}=", value)
  end
end
