Rails.application.routes.draw do
  if Netzke::Core.default_routes &&
      !Rails.application.routes.named_routes.routes[:netzke]
    netzke
  end
end
