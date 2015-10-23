module ExtensionTwo
  extend ActiveSupport::Concern
  included do
    client_class do |c|
      c.mixin :extension_two
    end
  end
end
