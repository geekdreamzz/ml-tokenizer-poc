Epiphany::Engine.routes.draw do
  root to: 'home#index'
  resources :test_phrases
end
