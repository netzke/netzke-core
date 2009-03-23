class Hash

  # Recursively convert the keys. Example:
  # irb> {:bla_bla => 1, "wow_now" => {:look_ma => true}}.convert_keys{|k| k.camelize} 
  # irb> => {:BlaBla => 1, "WowNow" => {:LookMa => true}}
  def convert_keys(&block)
    block_given? ? self.inject({}) do |h,(k,v)|
      h[k.is_a?(Symbol) ? yield(k.to_s).to_sym : yield(k.to_s)] = v.respond_to?('convert_keys') ? v.convert_keys(&block) : v
      h
    end : self
  end
  
  # First camelizes the keys, then convert the whole hash to JSON
  def to_js
    self.recursive_delete_if_nil.convert_keys{|k| k.camelize(:lower)}.to_json
  end

  # Converts values to strings
  def stringify_values!
    self.each_pair{|k,v| self[k] = v.to_s if v.is_a?(Symbol)}
  end
  
  # We don't need to pass null values in JSON, they are null by simply being absent
  def recursive_delete_if_nil
    self.inject({}) do |h,(k,v)|
      if !v.nil?
        h[k] = v.respond_to?('recursive_delete_if_nil') ? v.recursive_delete_if_nil : v
      end
      h
    end
  end
  
end

class Array
  # Camelizes the keys of hashes and converts them to JSON
  def to_js
    self.recursive_delete_if_nil.map{|el| el.is_a?(Hash) ? el.convert_keys{|k| k.camelize(:lower)} : el}.to_json
  end
  
  # Applies convert_keys to each element which responds to convert_keys
  def convert_keys(&block)
    block_given? ? self.map do |i|
      i.respond_to?('convert_keys') ? i.convert_keys(&block) : i
    end : self
  end
  
  def recursive_delete_if_nil
    self.map{|el| el.respond_to?('recursive_delete_if_nil') ? el.recursive_delete_if_nil : el}
  end
end

class String
  # Converts self to "literal JSON"-string - one that doesn't get quotes appended when being sent "to_json" method
  def l
    def self.to_json(options={})
      self
    end
    self
  end
  
  def to_js
    self.camelize(:lower)
  end
  
  # removes JS-comments (both single- and multi-line) from the string
  def strip_js_comments
    regexp = /\/\/.*$|(?m:\/\*.*?\*\/)/
    self.gsub!(regexp, '')

    # also remove empty lines
    regexp = /^\s*\n/
    self.gsub!(regexp, '')
  end
end

class Symbol
  def to_js
    self.to_s.camelize(:lower).to_sym
  end
end

module ActiveSupport
  class TimeWithZone
    def to_json
      self.to_s(:db).to_json
    end
  end
end