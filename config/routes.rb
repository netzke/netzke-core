Rails.application.routes.draw do
  if Netzke::Core.default_routes
    netzke unless Rails.application.routes.named_routes.routes[:netzke]
  end
end
