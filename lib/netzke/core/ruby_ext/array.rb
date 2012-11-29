class Array
  def deep_map(&block)
    self.map{ |el| el.respond_to?(:deep_map) ? block.call(el.deep_map(&block)) : block.call(el) }.compact
  end

  def jsonify
    self.map{ |el| el.is_a?(Array) || el.is_a?(Hash) ? el.jsonify : el }
  end

  # Camelizes the keys of hashes and converts them to JSON
  def to_nifty_json
    self.jsonify.to_json
  end

  def deep_each_pair(&block)
    self.each{ |el| el.respond_to?('deep_each_pair') && el.deep_each_pair(&block) }
  end

  def deep_freeze
    each { |j| j.deep_freeze if j.respond_to? :deep_freeze }
    freeze
  end
end
