class FriendshipsController < ApplicationController
  respond_to :json

  before_filter :find_friendship, :only => [:show, :update, :approve, :destroy]

  def index
    @friendships = Friendship.find_for_user_or_friend(@authenticated_user.id)    
    respond_with @friendships
  end
  
  def requested
    @friendships = @authenticated_user.friendships.unapproved
    respond_with @friendships, :template => 'friendships/index'
  end
  
  def pending
    @friendships = @authenticated_user.inverse_friendships.unapproved
    respond_with @friendships, :template => 'friendships/index'
  end

  def show
    respond_with @friendship
  end
  
  def create
    @friendship = @authenticated_user.friendships.build(params[:friendship])
    
    if @friendship.save
      respond_with @friendship, :status => :created, :location => me_friendship_path(@friendship)
    else
      respond_with @friendship, :status => :unprocessable_entity
    end
  end

  def update
    if @friendship.approve! @authenticated_user
      respond_with @friendship, :status => 200, :location => me_friendship_path(@friendship)
    else
      render json: { 
        :error => "You do not have permission to approve this friendship. Only those who receive requests can approve them." 
      }, :status => 500
    end
  end
  
  def destroy
    if @friendship.can_be_modified_by @authenticated_user
      if @friendship.destroy
        respond_with(:nothing => true) 
      end
    else
      json_unauthorized "You are not authorized to modify this friendship."
    end
  end
  
  private
  
  def find_friendship
    @friendship = Friendship.find_by_id(params[:id])

    if @friendship.nil?
      json_not_found("A friendship with an ID of #{params[:id]} could not be found.")
    end
  end

end