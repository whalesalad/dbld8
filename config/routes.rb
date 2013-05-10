DoubleDate::Application.routes.draw do
  # Invitation
  get 'invite(/:invite_slug)' => 'home#invite', :as => 'user_invitation'
  
  # Download
  get 'download' => 'static#download', :as => 'download'
  
  # Ssocial
  get 'facebook' => redirect("https://www.facebook.com/DoubleDateApp"), :as => 'facebook'
  get 'twitter' => redirect("https://twitter.com/DoubleDateApp"), :as => 'twitter'

  # Authentication
  post 'authenticate' => 'users#authenticate'
  get 'logout' => 'users#logout'

  # Feeds
  get 'feed/:slug' => 'feed#index', slug: /\w+/

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

    # post 'ping' => 'me#ping'

    # User Photos
    resource :photo, :controller => 'user_photo', :only => [:show, :create, :update] do
      # get the users current facebook photo
      get 'facebook', :on => :collection

      post 'pull_facebook', :on => :collection
    end

    resources :notifications, :only => [:index, :show, :destroy]

    resources :purchases, :only => [:index, :create, :show]

    # resource :device, :only => [:update, :destroy]
    put 'device' => 'me#update_device_token', :as => :update_device_token

    # Endpoint to receive feedback for a user
    post 'feedback' => 'me#receive_feedback', :as => :receive_feedback

    # get list of friends
    # GET /me/friends
    resources :friends, :only => [:index, :update, :destroy] do
      post 'approve' => :update, :on => :member

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
    get 'cities', :on => :collection
    get 'venues', :on => :collection
    get 'current', :on => :collection
  end

  # resources :packages, :controller => 'coin_packages', :only => [:index]
  resources :coin_packages, :path => 'packages', :only => [:index]

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

    resources :purchases

    resources :feedback

    require 'sidekiq/web'
    mount Sidekiq::Web, :at => 'sidekiq', :as => 'sidekiq'
  end

  # resources :stats
  get 'stats/users'
  get 'stats/users_by_country'
  get 'stats/activities'
  get 'stats/events'

  match "*slug" => 'static#show', :as => :static, :constraints => /\A[[\w\-]+[\/?]*]+\Z/, :via => :get

  # Home
  root :to => 'home#index'

end
