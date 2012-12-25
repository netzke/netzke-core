class Hash
  def netzke_deep_map(&block)
    self.dup.tap do |h|
      h.each_pair do |k,v|
        h[k] = v.netzke_deep_map(&block) if v.respond_to?('netzke_deep_map')
      end
    end
  end

  def deep_each_pair(&block)
    self.each_pair do |k,v|
      v.respond_to?('deep_each_pair') ? v.deep_each_pair(&block) : yield(k,v)
    end
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
