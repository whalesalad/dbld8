class EngagementsController < ApiController
  before_filter :get_activity, :only => [:show, :create, :destroy]
  before_filter :get_engagement, :only => [:show, :unlock, :destroy]
  before_filter :participants_only, :only => [:show, :destroy]

  def index
    @engagements = Engagement.for_user(@authenticated_user).reject do |engagement|
      engagement.ignored && engagement.activity.participant_ids.include?(@authenticated_user.id)
    end
  end

  def create
    if @activity.engagements.find_for_user_or_wing(@authenticated_user).exists?
      return json_unauthorized t('engagement.already_engaged')
    end

    message_body = params[:engagement].delete(:message)

    if message_body.nil?
      return json_error t('engagement.no_message')
    end

    @engagement = @activity.engagements.new(params[:engagement])
    @engagement.user = @authenticated_user

    ActiveRecord::Base.transaction do
      @engagement.save!

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
      return json_error t('engagement.current_user_cannot_unlock')
    end

    # If the engagement was already unlocked
    if @engagement.unlocked?
      return json_error t('engagement.already_unlocked')
    end

    # Finally, let's unlock this beast.
    if unlocker.unlock!
      respond_with @engagement,
        :location => engagement_path(@engagement), 
        :template => 'engagements/show' and return
    else
      return json_error t('engagement.unlock_error')
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

    json_error t('engagement.destroy_error')
  end

  private

  def engagement_id
    params[:id]
  end

  def activity_id
    if params[:engagement] && params[:engagement][:activity_id]
      params[:engagement][:activity_id]
    else
      params[:activity_id]
    end
  end

  def get_activity
    @activity = Activity.find_by_id(activity_id)
  end

  def get_engagement
    @engagement = if @activity.nil?
      Engagement.find_by_id(engagement_id)
    else
      @activity.engagements.find_for_user_or_wing(@authenticated_user).first
    end
    
    return json_not_found t('engagement.not_found') if @engagement.nil?
  end

  # only activity.participants can view index
  def participants_only
    return unauthorized! unless @engagement.allowed?(@authenticated_user, :all)
  end

end