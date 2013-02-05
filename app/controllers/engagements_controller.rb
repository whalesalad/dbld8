class EngagementsController < ApplicationController
  respond_to :json

  before_filter :get_activity, :only => [:show]
  before_filter :get_engagement, :only => [:show, :unlock, :destroy]
  before_filter :participants_only, :only => [:show, :destroy]

  def index
    @engagements = Engagement.for_user(@authenticated_user)
    respond_with @engagements
  end

  def create
    if @activity.engagements.find_for_user_or_wing(@authenticated_user).exists?
      return json_unauthorized "You or your wing have already engaged in this activity."
    end

    message_body = params[:engagement].delete(:message)

    if message_body.nil?
      return json_error "You must include a message body with your engagement."
    end

    params[:engagement][:user_id] = @authenticated_user.id

    ActiveRecord::Base.transaction do
      @engagement = @activity.engagements.create(params[:engagement])

      # Send the first message for this engagement
      # I'd like to hook this to the after_create event
      # but there is no way to cache the message text for this
      @engagement.send_initial_message(message_body)

      # Finally, respond
      respond_with @engagement, 
        :status => :created, 
        :location => engagement_path(@engagement), 
        :template => 'engagements/show' and return
    end
    
    respond_with @engagement, :status => :unprocessable_entity
  end

  def show
    respond_with @engagement
  end

  def unlock
    # simple POST will perform the unlock
    unlocker = UnlockEngagementService.new(@engagement, @authenticated_user)

    # If the user is unable to unlock
    unless unlocker.unlockable?
      return json_error "The current user cannot unlock this engagement."
    end

    # If the engagement was already unlocked
    if @engagement.unlocked?
      return json_error "This engagement has already been unlocked"
    end

    # Finally, let's unlock this beast.
    if unlocker.unlock!
      respond_with @engagement,
        :location => activity_engagement_path(@activity, @engagement), 
        :template => 'engagements/show' and return
    else
      return json_error "An error ocurred unlocking this engagement."
    end
  end

  def destroy
    # if the user is the owner of the engagement, actually delete it.
    if @engagement.allowed?(@authenticated_user, :owner)
      if @engagement.destroy
        respond_with(:nothing => true) and return
      end
    # if the user is the owner of the activity, set status to ignored
    elsif @engagement.activity.allowed?(@authenticated_user, :owner)
      if @engagement.ignore!
        respond_with(:nothing => true) and return
      end
    end

    json_error "An error occured deleting this engagement."
  end

  private

  def engagement_id
    params[:id]
  end

  def get_activity
    @activity = Activity.find_by_id(params[:activity_id])
  end

  def get_engagement
    @engagement = if @activity.nil?
      Engagement.find_by_id(engagement_id)
    else
      @activity.engagements.find_for_user_or_wing(@authenticated_user).first
    end
    
    return json_not_found "You have not engaged in this activity yet, "\
      "or the engagement was not found." if @engagement.nil?
  end

  # only activity.participants can view index
  def participants_only
    return unauthorized! unless @engagement.allowed?(@authenticated_user, :all)
  end

end