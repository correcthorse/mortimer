Mortimer::Application.routes.draw do
  
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login

  resources :users do
    member do
      post 'toggle_admin'
      post 'reset_password'
    end
  end
  resource  :user_password, :session
  resources :settings, :groups, :entries, :permissions
  
  root :to => 'groups#index', :as => :home
end
