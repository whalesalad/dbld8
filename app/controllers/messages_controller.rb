class MessagesController < ApplicationController
  respond_to :json
  
  before_filter :get_activity, :get_engagement, :unauthorized!
  before_filter :get_message, :only => [:show, :destroy]
  
  def index
    respond_with @engagement.messages.order('created_at ASC')
  end

  def show
    respond_with @message
  end

  def create
    # render json: @engagement.messages.where(:user_id => @authenticated_user.id) and return
    @message = @engagement.messages.new({
      :message => params[:message],
      :user_id => @authenticated_user.id
    })

    if @message.save
      # Accept the engagement if the owner is replying.
      if @engagement.messages.where(:user_id => @authenticated_user.id).count == 1
        @activity.accept_engagement! @engagement
      end

      respond_with @message, :status => :created, 
        :location => activity_engagement_messages_path(@activity, @engagement)
    else
      respond_with @message, :status => :unprocessable_entity
    end
  end

  def destroy
    unless @message.allowed?(@authenticated_user, :modify)
      json_unauthorized "The authenticated user does not have " \
        "permission to delete this message." and return
    end

    if @message.destroy
      respond_with(:nothing => true)
    end
  end

private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
    json_not_found "The requested activity was not found." if @activity.nil?
    @activity.update_relationship_as(@authenticated_user)
  end

  def get_engagement
    if params.include? :engagement_id
      @engagement = if params[:engagement_id] == 'mine'
        @activity.engagements.find_for_user_or_wing(@authenticated_user.id)
      else
        @activity.engagements.find_by_id(params[:engagement_id])
      end
    else
      @engagement = @activity.accepted_engagement
    end
  end

  def get_message
    @message = @engagement.messages.find_by_id(params[:id])
    json_not_found "The requested message was not found." if @message.nil?
  end

  def unauthorized!
    unless @engagement.allowed?(@authenticated_user, :all)
      json_unauthorized "The authenticated user does not have \
      permission to modify or delete this activity."
    end
  end

end