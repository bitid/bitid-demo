BitidDemo::Application.routes.draw do
  root to: 'home#index'
  match '/login', to: 'home#login'

  resources :callback, only: :create
end