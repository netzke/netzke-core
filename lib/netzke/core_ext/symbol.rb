class Symbol
  def jsonify
    self.to_s.jsonify.to_sym
  end

  def l
    ActiveSupport::JSON::Variable.new(self.to_s)
  end

  def to_cls_attr
    "__#{self}__".to_sym
  end
end
