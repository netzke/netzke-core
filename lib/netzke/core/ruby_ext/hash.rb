class Hash
  def netzke_deep_map(&block)
    self.dup.tap do |h|
      h.each_pair do |k,v|
        h[k] = v.netzke_deep_map(&block) if v.respond_to?('netzke_deep_map')
      end
    end
  end

  def netzke_deep_replace(&block)
    self.dup.tap do |h|
      h.each_pair do |k,v|
        if v.is_a?(Hash)
          res = yield(v)
          if res == v # no changes, need to go further down
            h[k] = v.netzke_deep_replace(&block) if v.respond_to?('netzke_deep_replace')
          else
            h[k] = res
          end
        else
          if v.is_a?(Array)
            h[k] = v.netzke_deep_replace(&block)
          end
        end
      end
    end
  end

  def netzke_jsonify
    self.inject({}) do |h,(k,v)|
      new_key = if k.is_a?(Netzke::Core::JsonLiteral)
                  k
                elsif k.is_a?(String)
                  k.camelize(:lower)
                elsif k.is_a?(Symbol)
                  k.to_s.camelize(:lower).to_sym
                else
                  k
                end

      new_value = case v
                  when Array, Hash
                    v.netzke_jsonify
                  when Class, Proc
                    v.to_s
                  else
                    v
                  end

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
    self
  end

  def netzke_literalize_keys
    netzke_update_keys{ |k| Netzke::Core::JsonLiteral.new(k.to_s) }
    self
  end
end
