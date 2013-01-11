DoubleDate::Application.routes.draw do

  post 'users/build' => 'users#build_facebook_user', :as => 'build_user'

  post 'authenticate' => 'users#authenticate'

  get 'invite(/:invite_slug)' => 'users#invitation', :as => 'user_invitation'

  get 'itunes' => redirect(Rails.configuration.app_store_url), :as => 'itunes'

  resources :users, :only => [:index, :show, :create] do
    get 'search', :on => :collection
  end

  resources :activities do
    get 'mine', :on => :collection
    get 'other', :on => :collection
    get 'engaged', :on => :collection

    resources :engagements do
      resources :messages
    end

    resources :messages
  end

  # ME!
  resource :me, :controller => "me" do
    # User Photos
    resource :photo, :controller => 'user_photo', :only => [:show, :create]

    # get list of friends
    # GET /me/friends
    resources :friends, :only => [:index, :update, :destroy] do
      get 'facebook', :on => :collection

      # /me/friends/invite { facebook_ids: 109234, 23492349, 29349234 }
      post 'invite', :on => :collection
    end
  end

  # Interests
  resources :interests, :only => [:index, :show]

  # Locations
  resources :locations, :only => [:index, :show] do
    get 'both', :on => :collection
    get 'cities', :on => :collection
    get 'venues', :on => :collection
  end

  # Admin
  namespace :admin do
    match '', :action => 'index'
    
    resources :users, :only => [:index, :show, :destroy] do
      get 'photos', :on => :member
    end

    resources :friendships
    
    resources :activities do
      get 'engaged', :on => :collection
      get 'expired', :on => :collection
    end

    resources :facebook_invites, :only => [:index] do
      post 'destroy_multiple', :on => :collection
    end

    resources :interests, :only => [:index, :show]

    resources :locations, :only => [:index, :show] do
      get 'cities', :on => :collection
      get 'venues', :on => :collection
    end

    resources :user_actions, :only => [:index]

    require 'sidekiq/web'
    mount Sidekiq::Web, :at => 'sidekiq', :as => 'sidekiq'
    # mount Resque::Server, :at => 'resque', :as => 'resque'
  end

  # Home
  root :to => 'home#index'

end
