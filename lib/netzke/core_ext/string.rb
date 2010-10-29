class String
  def jsonify
    self.camelize(:lower)
  end

  # Converts self to "literal JSON"-string - one that doesn't get quotes appended when being sent "to_json" method
  def l
    ActiveSupport::JSON::Variable.new(self)
  end

  # removes JS-comments (both single- and multi-line) from the string
  def strip_js_comments
    regexp = /\/\/.*$|(?m:\/\*.*?\*\/)/
    self.gsub!(regexp, '')

    # also remove empty lines
    regexp = /^\s*\n/
    self.gsub!(regexp, '')
  end

  # "false" => false, "whatever_else" => true
  def to_b
    self != "false"
  end

end
