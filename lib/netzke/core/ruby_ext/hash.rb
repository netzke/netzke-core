class Hash
  def netzke_deep_map(&block)
    self.dup.tap do |h|
      h.each_pair do |k,v|
        h[k] = v.netzke_deep_map(&block) if v.respond_to?('netzke_deep_map')
      end
    end
  end

  def netzke_jsonify
    self.inject({}) do |h,(k,v)|
      new_key = if k.is_a?(ActiveSupport::JSON::Variable)
                  k
                elsif k.is_a?(String)
                  k.camelize(:lower)
                elsif k.is_a?(Symbol)
                  k.to_s.camelize(:lower).to_sym
                else
                  k
                end

      new_value = v.is_a?(Array) || v.is_a?(Hash) ? v.netzke_jsonify : v

      h.merge(new_key => new_value)
    end
  end

  # From http://rubyworks.github.com/facets
  def netzke_update_keys #:yield:
    if block_given?
      keys.each { |old_key| store(yield(old_key), delete(old_key)) }
    else
      to_enum(:netzke_update_keys)
    end
  end

  def netzke_literalize_keys
    netzke_update_keys{ |k| ActiveSupport::JSON::Variable.new(k.to_s) }
    self
  end
end
