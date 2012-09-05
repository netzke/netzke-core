class String
  def jsonify
    if self.index('_') == 0
      # '_some_string' should become '_someString' and not 'SomeString'
      '_' + self[1..-1].camelize(:lower)
    else
      self.camelize(:lower)  
    end
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
