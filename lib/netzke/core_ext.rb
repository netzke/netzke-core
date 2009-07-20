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

  def jsonify
    self.inject({}) do |h,(k,v)|
      new_key = k.instance_of?(String) || k.instance_of?(Symbol) ? k.jsonify : k
      new_value = v.instance_of?(Array) || v.instance_of?(Hash) ? v.jsonify : v
      h.merge(new_key => new_value)
    end
  end
  
  # First camelizes the keys, then convert the whole hash to JSON
  def to_nifty_json
    self.recursive_delete_if_nil.jsonify.to_json
  end
  
  # Converts values of a Hash in such a way that they can be easily stored in the database: hashes and arrays are jsonified, symbols - stringified
  def deebeefy_values
    inject({}) do |options, (k, v)|
      options[k] = v.is_a?(Symbol) ? v.to_s : (v.is_a?(Hash) || v.is_a?(Array)) ? v.to_json : v
      options
    end
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

  # Javascrit-like access to Hash values
  def method_missing(method, *args)
    if method.to_s =~ /=$/ 
      method_base = method.to_s.sub(/=$/,'').to_sym
      key = self[method_base.to_s].nil? ? method_base : method_base.to_s
      self[key] = args.first
    else
      key = self[method.to_s].nil? ? method : method.to_s
      self[key]
    end
  end
  
end

class Array
  def jsonify
    self.map{ |el| el.instance_of?(Array) || el.instance_of?(Hash) ? el.jsonify : el }
  end
  
  # Camelizes the keys of hashes and converts them to JSON
  def to_nifty_json
    self.recursive_delete_if_nil.jsonify.to_json
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

class LiteralString < String
  def to_json(*args)
    self
  end
end

class String
  def jsonify
    self.camelize(:lower)
  end
  
  # Converts self to "literal JSON"-string - one that doesn't get quotes appended when being sent "to_json" method
  def l
    LiteralString.new(self)
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

class Symbol
  def jsonify
    self.to_s.camelize(:lower).to_sym
  end
  
  def l
    LiteralString.new(self.to_s)
  end
end

module ActiveSupport
  class TimeWithZone
    def to_json(options = {})
      self.to_s(:db).to_json
    end
  end
end