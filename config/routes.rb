DoubleDate::Application.routes.draw do
  # post 'users/build' => 'users#build_facebook_user', :as => 'build_user'
  # post 'users/create' => 'users#create_facebook_user', :as => 'create_user'

  get 'new' => 'home#new'
  get 'about' => 'static#about'
  get 'terms' => 'static#terms'
  get 'privacy' => 'static#privacy'

  get 'invite(/:invite_slug)' => 'users#invitation', :as => 'user_invitation'

  get 'appstore' => redirect(Rails.configuration.app_store_url), :as => 'appstore'

  # Authentication
  post 'authenticate' => 'users#authenticate'
  get 'logout' => 'users#logout'

  resources :users, :only => [:index, :show, :create] do
    get 'search', :on => :collection
    post 'invite', :on => :member
  end

  resources :activities do
    get 'mine', :on => :collection
    get 'engaged', :on => :collection

    # Singular resource for the user interested
    resource :engagement, :only => [:create, :show, :destroy]
  end

  resources :engagements do
    # allows an owner/wing to unlock an engagement
    post 'unlock', :on => :member
    resources :messages
  end

  # ME!
  resource :me, :controller => "me" do
    get 'unlock(/:slug)' => 'me#check_unlock'
    post 'unlock(/:slug)' => 'me#perform_unlock'

    # User Photos
    resource :photo, :controller => 'user_photo', :only => [:show, :create] do
      post 'pull_facebook', :on => :collection
    end

    resources :notifications, :only => [:index, :show]

    # resource :device, :only => [:update, :destroy]
    put 'device' => 'me#update_device_token', :as => :update_device_token

    # get list of friends
    # GET /me/friends
    resources :friends, :only => [:index, :update, :destroy] do
      get 'facebook', :on => :collection

      # /me/friends/invite { facebook_ids: 109234, 23492349, 29349234 }
      post 'invite', :on => :collection

      post 'invite_connect', :on => :collection
      post 'request_connect', :on => :collection

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

  # resources :packages, :controller => 'coin_packages', :only => [:index]
  resources :coin_packages, :path => 'packages', :only => [:index]

  get 'cron/(:task)' => 'cron#run_task'

  # Admin
  namespace :admin do
    match '', :action => 'index'
    
    resources :users, :only => [:index, :show, :destroy] do
      get 'photos', :on => :member
      get 'send_push', :on => :member
    end

    resources :friendships
    
    resources :activities, :only => [:index, :show, :destroy] do
      get 'engaged', :on => :collection
      get 'expired', :on => :collection
    end

    resources :engagements, :only => [:index, :show, :destroy] do
      resources :messages, :only => [:index, :show]
      post 'unlock', :on => :member
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

    resources :coin_packages, :path => 'packages'

    require 'sidekiq/web'
    mount Sidekiq::Web, :at => 'sidekiq', :as => 'sidekiq'
    # mount Resque::Server, :at => 'resque', :as => 'resque'
  end

  # Home
  root :to => 'home#index'

end
