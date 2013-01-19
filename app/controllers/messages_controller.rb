class MessagesController < ApplicationController
  respond_to :json
  
  before_filter :get_activity, :get_engagement
  before_filter :get_message, :only => [:show, :destroy]

  def index
    @messages = @engagement.messages
    respond_with @messages
  end

  def show
    respond_with @message
  end

  def create
    @message = @engagement.messages.new({
      :body => params[:message][:body],
      :user_id => @authenticated_user.id
    })

    if @message.save
      respond_with @message, :status => :created, 
        :location => activity_engagement_messages_path(@activity, @engagement),
        :template => 'messages/show'
    else
      respond_with @message, :status => :unprocessable_entity
    end
  end

  def destroy
    unless @message.allowed?(@authenticated_user, :all)
      return json_unauthorized "The authenticated user does not have "\
      "permission to delete this message."
    end

    respond_with(:nothing => true) if @message.destroy
  end

  private

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
    json_not_found "The requested activity was not found." if @activity.nil?
    # @activity.update_relationship_as(@authenticated_user)
  end

  def get_engagement
    @engagement = if params[:engagement_id] == 'mine'
      @activity.engagements.find_for_user_or_wing(@authenticated_user.id)
    else
      @activity.engagements.find_by_id(params[:engagement_id])
    end

    json_not_found "The requested engagement was not found." if @engagement.nil?
  end

  def get_message
    @message = @engagement.messages.find_by_id(params[:id])
    json_not_found "The requested message was not found." if @message.nil?
  end

end