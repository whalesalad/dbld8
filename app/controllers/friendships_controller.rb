class FriendshipsController < ApplicationController
  before_filter :find_friendship, :only => [:show, :approve, :destroy]
  
  respond_to :json

  def index
    id = @authenticated_user.id
    
    @friendships = Friendship.find_all_by_user_id(id) | Friendship.find_all_by_friend_id(id)
    
    respond_with @friendships
  end
  
  def show
    respond_with @friendship
  end
  
  def approve
    if @friendship.approve! @authenticated_user
      respond_with @friendship, :status => 200, :location => me_friendship_path(@friendship)
    else
      render json: { :error => "You do not have permission to approve this friendship. Only those who receive requests can approve them." }, :status => 500
    end
  end
  
  def requested
    respond_with @authenticated_user.friendships.unapproved
  end
  
  def pending
    respond_with @authenticated_user.inverse_friendships.unapproved
  end

  def create
    @friendship = @authenticated_user.friendships.build(params[:friendship])
    
    if @friendship.save
      respond_with @friendship, :status => :created, :location => me_friendship_path(@friendship)
    else
      respond_with @friendship, :status => :unprocessable_entity
    end
  end
  
  def destroy
    # Friendship.destroy!
  end
  
  private
  
  def find_friendship
    @friendship = Friendship.find_by_id(params[:id])
  end

end