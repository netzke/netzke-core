Rails.application.routes.draw do
  netzke unless Rails.application.routes.named_routes.key? :netzke
end
