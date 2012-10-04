DoubleDate::Application.routes.draw do
  
  post 'users/build' => 'users#build_facebook_user', :as => 'build_user'

  post 'authenticate' => 'users#authenticate'
  
  get 'invite/:uuid' => 'users#invitation'

  # ways to find other users
  # email
  # facebook id
  resources :users, :only => [:index, :show, :create] do
    get 'search', :on => :collection
  end

  # ME!
  resource :me, :controller => "me" do
    # User Photos
    resource :photo, :controller => 'user_photo', :only => [:show, :create]

    # get list of friends
    # GET /me/friends
    resources :friends, :only => [:index]
    
    resources :friendships, :only => [:index, :show, :create, :delete] do
      # approve a pending friendship request
      # POST /me/friendships/:friendship_id/approve
      post 'approve', :on => :member
      
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
  resources :locations, :only => [:index, :show]

  # Admin
  namespace :admin do
    match '', :action => 'index'
    resources :users, :only => [:index, :show, :destroy]
    resources :friendships
    resources :interests, :only => [:index, :show]
    resources :locations, :only => [:index, :show]
  end

  # Home
  root :to => 'home#index'
  
end
