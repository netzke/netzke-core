class Symbol
  def jsonify
    self.to_s.camelize(:lower).to_sym
  end

  def l
    ActiveSupport::JSON::Variable.new(self.to_s)
  end

  def action(config = {})
    config.merge(:action => self)
  end

  def component(config = {})
    config.merge(:netzke_component => self)
  end

  def to_cls_attr
    "__#{self}__".to_sym
  end
end
