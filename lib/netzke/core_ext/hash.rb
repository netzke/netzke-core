class Hash
  def deep_map(&block)
    self.dup.tap do |h|
      h.each_pair do |k,v|
        h[k] = v.deep_map(&block) if v.respond_to?('deep_map')
      end
    end
  end

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
      new_key = (k.is_a?(String) || k.is_a?(Symbol)) && !k.is_a?(ActiveSupport::JSON::Variable) ? k.jsonify : k
      new_value = v.is_a?(Array) || v.is_a?(Hash) ? v.jsonify : v
      h.merge(new_key => new_value)
    end
  end

  # First camelizes the keys, then convert the whole hash to JSON
  def to_nifty_json
    self.jsonify.to_json
  end

  # Converts values of a Hash in such a way that they can be easily stored in the database: hashes and arrays are jsonified, symbols - stringified
  def deebeefy_values
    inject({}) do |options, (k, v)|
      options[k] = v.is_a?(Symbol) ? v.to_s : (v.is_a?(Hash) || v.is_a?(Array)) ? v.to_json : v
      options
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

  # From http://rubyworks.github.com/facets
  def update_keys #:yield:
    if block_given?
      keys.each { |old_key| store(yield(old_key), delete(old_key)) }
    else
      to_enum(:update_keys)
    end
  end

  def literalize_keys
    update_keys{ |k| k.to_s.l }
    self
  end

end
