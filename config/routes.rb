DoubleDate::Application.routes.draw do
  
  post 'users/build' => 'users#build_facebook_user', :as => 'build_user'

  post 'authenticate' => 'users#authenticate'

  namespace :dev do
    get 'users'
    get 'users/:id', :action => 'user_detail', :as => 'user_detail'
  end

  resources :users, :only => [:index, :show, :create]

  # ME!
  resource :me, :controller => "me" do
    resource :photo, :controller => 'user_photo', :only => [:show, :create]
  end

  # Interests
  resources :interests, :only => [:index, :show]

  # Locations
  resources :locations, :only => [:index, :show] do
    get 'search', :on => :collection
  end

  # Home
  root :to => 'home#index'
  
end
