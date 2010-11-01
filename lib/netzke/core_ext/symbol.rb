class Symbol
  def jsonify
    self.to_s.camelize(:lower).to_sym
  end

  def l
    ActiveSupport::JSON::Variable.new(self.to_s)
  end

  def action(config = {})
    config.merge(:action => self.to_s)
  end

  def component(config = {})
    config.merge(:component => self.to_s)
  end
end
