module Netzke
  module Widget
    # Panel is a widget that supports automatic handling of actions. Later that functionality may be extracted to a separate module.
    class Panel < Base
      include Widget::Actions
    end
  end
end