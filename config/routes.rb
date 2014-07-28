Resistance::Application.routes.draw do

  root :to => 'users#new'

  resources :game_invitees, only: [:new, :create] 
  resources :games, only: [:new, :create, :show] 

  resources :user_sessions

  get 'login' => "user_sessions#new", as: :login
  post 'logout' => "user_sessions#destroy", as: :logout

  resources :users
  resource :user, :as => 'account'

  get 'signup' => 'users#new', :as => :signup

end
