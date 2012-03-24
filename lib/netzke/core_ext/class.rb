class Class
  unless defined? read_inheritable_attribute
    def read_inheritable_attribute(attr)
      cls_attr = attr.to_cls_attr
      create_inheritable_attribute(cls_attr) unless self.respond_to?(cls_attr)
      self.send(cls_attr)
    end

    def write_inheritable_attribute(attr, value)
      cls_attr = attr.to_cls_attr
      create_inheritable_attribute(cls_attr) unless self.respond_to?(cls_attr)
      self.send("#{cls_attr}=", value)
    end

    private
    def create_inheritable_attribute(attr)
      self.class_eval <<-RUBY
        class_attribute :#{attr}
      RUBY
    end
  end
end
