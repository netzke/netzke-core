# This is an example of dividing component's code into modules. Use it to build complex components.
class KindaComplexComponent < Netzke::Base
  include KindaComplexComponentLib::BasicStuff
  include KindaComplexComponentLib::ExtraStuff
end
