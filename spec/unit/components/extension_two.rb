module ExtensionTwo
  extend ActiveSupport::Concern
  included do
    client_class do |c|
      c.include :extension_two
    end
  end
end
