class Array
  def netzke_deep_map(&block)
    self.map{ |el| el.respond_to?(:netzke_deep_map) ? block.call(el.netzke_deep_map(&block)) : block.call(el) }.compact
  end

  def netzke_jsonify
    self.map{ |el| el.is_a?(Array) || el.is_a?(Hash) ? el.netzke_jsonify : el }
  end
end
