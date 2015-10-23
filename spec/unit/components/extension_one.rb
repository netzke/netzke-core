module ExtensionOne
  extend ActiveSupport::Concern
  included do
    client_class do |c|
      c.mixin :extension_one
    end
  end
end
