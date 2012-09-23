class Array
  def deep_map(&block)
    self.map{ |el| el.respond_to?(:deep_map) ? block.call(el.deep_map(&block)) : block.call(el) }
  end

  def jsonify
    self.map{ |el| el.instance_of?(Array) || el.instance_of?(Hash) ? el.jsonify : el }
  end

  # Camelizes the keys of hashes and converts them to JSON
  def to_nifty_json
    self.recursive_delete_if_nil.jsonify.to_json
  end

  # Applies deep_convert_keys to each element which responds to deep_convert_keys
  def deep_convert_keys(&block)
    block_given? ? self.map do |i|
      i.respond_to?('deep_convert_keys') ? i.deep_convert_keys(&block) : i
    end : self
  end

  def deep_each_pair(&block)
    self.each{ |el| el.respond_to?('deep_each_pair') && el.deep_each_pair(&block) }
  end

  def recursive_delete_if_nil
    self.map{|el| el.respond_to?('recursive_delete_if_nil') ? el.recursive_delete_if_nil : el}
  end

  def deep_freeze
    each { |j| j.deep_freeze if j.respond_to? :deep_freeze }
    freeze
  end
end
