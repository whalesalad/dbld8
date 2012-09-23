DoubleDate::Application.routes.draw do
  
  post 'users/build' => 'users#build_facebook_user', :as => 'build_user'

  post 'authenticate' => 'users#authenticate'

  resources :users, :only => [:index, :show, :create]

  # ME!
  resource :me, :controller => "me" do
    resource :photo, :controller => 'user_photo', :only => [:show, :create]
  end

  # Interests
  resources :interests, :only => [:index, :show]
  
  # Locations
  resources :locations, :only => [:index, :show]

  # Admin
  namespace :admin do
    match '', :action => 'index'
    resources :users, :only => [:index, :show, :destroy]
    resources :interests, :only => [:index, :show]
    resources :locations, :only => [:index, :show]
  end

  # Home
  root :to => 'home#index'
  
end
