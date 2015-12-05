require 'spec_helper'

module Netzke::Core
  describe Configuration do
    describe "#validate_config" do
      it "can override config" do
        class OverridingConfig < Netzke::Base
          def configure(c)
            super
            c.foo = "bar"
          end
          def validate_config(c)
            c.foo = "baz"
          end
        end

        expect(OverridingConfig.new.js_config[:foo]).to eql('baz')
      end
    end
  end
end
