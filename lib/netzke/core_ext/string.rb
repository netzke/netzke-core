class String
  def jsonify
    self.camelize(:lower)
  end

  # Converts self to "literal JSON"-string - one that doesn't get quotes appended when being sent "to_json" method
  # TODO: get rid of it
  def l
    ActiveSupport::JSON::Variable.new(self)
  end

  # removes JS-comments (both single- and multi-line) from the string
  def strip_js_comments
    if defined?(::Rails) && Rails.application.assets.js_compressor
      compressor = Rails.application.assets.js_compressor
      compressor.processor.call(nil, self)
    else
      self
    end
  end

  # "false" => false, "whatever_else" => true
  def to_b
    self != "false"
  end
end
