Rails.application.routes.draw do
  if Netzke::Core.default_routes
    netzke unless Rails.application.routes.named_routes.key? :netzke
  end
end
