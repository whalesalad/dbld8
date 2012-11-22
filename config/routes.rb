DoubleDate::Application.routes.draw do

  post 'users/build' => 'users#build_facebook_user', :as => 'build_user'

  post 'authenticate' => 'users#authenticate'

  get 'invite(/:invite_slug)' => 'users#invitation', :as => 'user_invitation'


  resources :users, :only => [:index, :show, :create] do
    get 'search', :on => :collection
  end


  resources :activities, :only => [:index, :show, :create, :destroy] do
    # GET /activities/mine, get all my activities (grouped)
    get 'mine', :on => :collection

    # /activities/10/engagements
    # /activities/10/engagements/12
    resources :engagements

  end


  # ME!
  resource :me, :controller => "me" do
    # User Photos
    resource :photo, :controller => 'user_photo', :only => [:show, :create]

    # get list of friends
    # GET /me/friends
    resources :friends, :only => [:index, :show, :destroy] do
      get 'facebook', :on => :collection

      # /me/friends/invite { facebook_ids: 109234, 23492349, 29349234 }
      post 'invite', :on => :collection
    end

    # POST /me/invite_friends
    # post 'invite_friends', :action => 'friends#invite_friends'

    resources :friendships, :only => [:index, :show, :update, :create, :destroy] do
      # ignore a pending friendship request (deletes it)
      # POST /me/friendships/:friendship_id/ignore
      post 'ignore', :on => :member

      # get list of pending friendships (others inviting me)
      # GET /me/friendships/pending
      get 'pending', :on => :collection

      # Get a list of users I have requested
      # GET /me/friendships/requested
      get 'requested', :on => :collection
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
    resources :users, :only => [:index, :show, :destroy]
    resources :friendships
    resources :activities

    resources :facebook_invites, :only => [:index] do
      post 'destroy_multiple', :on => :collection
    end

    resources :interests, :only => [:index, :show]

    resources :locations, :only => [:index, :show] do
      get 'cities', :on => :collection
      get 'venues', :on => :collection
    end

    resources :credit_actions, :only => [:index, :new, :create, :edit, :update]
    resources :user_actions, :only => [:index]

    mount Resque::Server, :at => 'resque', :as => 'resque'
  end

  # Home
  root :to => 'home#index'

end
