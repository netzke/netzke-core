class Hash
  def deep_each_pair(&block)
    self.each_pair do |k,v|
      v.respond_to?('deep_each_pair') ? v.deep_each_pair(&block) : yield(k,v)
    end
  end

  # Recursively convert the keys. Example:
  # {:bla_bla => 1, "wow_now" => {:look_ma => true}}.deep_convert_keys{|k| k.to_s.camelize.to_sym}
  #   => {:BlaBla => 1, "WowNow" => {:LookMa => true}}
  def deep_convert_keys(&block)
    block_given? ? self.inject({}) do |h,(k,v)|
      h[yield(k)] = v.respond_to?('deep_convert_keys') ? v.deep_convert_keys(&block) : v
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

  # add flatten_with_type method to Hash
  def flatten_with_type(preffix = "")
    res = []
    self.each_pair do |k,v|
      name = ((preffix.to_s.empty? ? "" : preffix.to_s + "__") + k.to_s).to_sym
      if v.is_a?(Hash)
        res += v.flatten_with_type(name)
      else
        res << {
          :name => name,
          :value => v,
          :type => (["TrueClass", "FalseClass"].include?(v.class.name) ? 'Boolean' : v.class.name).to_sym
        }
      end
    end
    res
  end

  def deep_freeze
    each { |k,v| v.deep_freeze if v.respond_to? :deep_freeze }
    freeze
  end

end
