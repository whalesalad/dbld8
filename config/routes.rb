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

    # Resources for the date owner
    resources :engagements do
      # allows an owner/wing to unlock an engagement
      post 'unlock', :on => :member
      resources :messages
    end

    # Singular resource for the user interested
    resource :engagement do
      resources :messages
    end
  end

  # ME!
  resource :me, :controller => "me" do
    # User Photos
    resource :photo, :controller => 'user_photo', :only => [:show, :create]

    # resources :notifications
    get 'notifications', :on => :member

    # resource :device, :only => [:update, :destroy]
    put 'device' => 'me#update_device_token', :as => :update_device_token

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
    
    resources :activities, :only => [:index, :show] do
      get 'engaged', :on => :collection
      get 'expired', :on => :collection

      resources :engagements, :only => [:index, :show] do
        resources :messages, :only => [:index, :show]
      end
    end

    resources :facebook_invites, :only => [:index] do
      post 'destroy_multiple', :on => :collection
    end

    resources :interests, :only => [:index, :show]

    resources :locations, :only => [:index, :show] do
      get 'cities', :on => :collection
      get 'venues', :on => :collection
      get 'page/:page', :action => :index, :on => :collection
    end

    resources :events, :only => [:index] do
      get 'page/:page', :action => :index, :on => :collection
    end

    require 'sidekiq/web'
    mount Sidekiq::Web, :at => 'sidekiq', :as => 'sidekiq'
    # mount Resque::Server, :at => 'resque', :as => 'resque'
  end

  # Home
  root :to => 'home#index'

end
