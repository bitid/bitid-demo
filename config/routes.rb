BitidDemo::Application.routes.draw do
  devise_for :users, controllers: {sessions: 'users/sessions'}

  root to: 'home#index'
  match '/login', to: 'home#login'
  match '/user', to: 'home#user'
  match '/auth', to: 'home#auth'

  resources :callback, only: :create
end