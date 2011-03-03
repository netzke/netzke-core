module Netzke
  module Core
    # Allows deep-nested configuration without previously defining the hash tree:
    #
    #     config = Netzke::Core::OptionsHash.new
    #     config.basepack.grid_panel.add_form.with_tools = true
    #     config
    #     => {:basepack=>{:grid_panel=>{:add_form=>{:with_tools=>true}}}}
    class OptionsHash < ::Hash
      def []=(key, value)
        super(key.to_sym, value)
      end

      def [](key)
        super(key.to_sym)
      end

      def method_missing(name, *args)
        if name.to_s =~ /(.*)=$/
          self[$1.to_sym] = args.first
        else
          self.has_key?(name) ? self[name] : self[name] = OptionsHash.new
        end
      end
    end
  end
end