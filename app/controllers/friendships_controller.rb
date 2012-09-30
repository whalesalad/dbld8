class FriendshipsController < ApplicationController
  before_filter :find_friendship, :only => [:show, :approve, :destroy]
  
  respond_to :json

  def index
    respond_with @authenticated_user.friendships
  end
  
  def show
    # @friendship = Friendship.find_by_id(params[:id])
    respond_with @friendship
  end
  
  def approve
    if @friendship.approve! @authenticated_user
      respond_with @friendship, :status => 200, :location => me_friendship_path(@friendship)
    else
      render json: { :error => "This friendship could not be approved." }, :status => 500
    end
  end
  
  def pending
    # respond_with @authenticated_user.friendships.unapproved
    # respond_with @authenticated_user.pending_friends
    @pending_friendships = Friendship.where(:approved => false, :friend_id => @authenticated_user.id)
    respond_with @pending_friendships
  end
  
  def requested
    respond_with @authenticated_user.friendships.where(:approved => false)
  end
  
  def create
    # render json: params[:friendship] and return
    @friendship = @authenticated_user.friendships.create(params[:friendship])
    
    if @friendship.save
      respond_with @friendship, :status => :created, :location => me_friendship_path(@friendship)
    else
      respond_with @friendship, :status => :unprocessable_entity
    end
    
  end
  
  def destroy
    
  end
  
  private
  
  def find_friendship
    @friendship = Friendship.find_by_id(params[:id])
  end

end