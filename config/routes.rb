Epiphany::Engine.routes.draw do
  root to: 'home#index'
  resources :phrases
  resources :entity_types
  resources :intents
  resources :analyzers
end
