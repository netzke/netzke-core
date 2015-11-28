module ExtensionOne
  extend ActiveSupport::Concern
  included do
    client_class do |c|
      c.include :extension_one
    end
  end
end
