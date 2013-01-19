class EngagementsController < BaseActivitiesController
  respond_to :json

  before_filter :get_activity
  before_filter :get_engagement, :only => [:show, :destroy]
  before_filter :activity_participants_only, :only => [:update]

  def index
    @engagements = if @activity.allowed?(@authenticated_user, :owners)
      # if the user is the user/wing
      @activity.engagements.not_ignored
    else
      # if we're a random user, respond with their singular engagement.
      [get_singular_engagement].compact
    end

    respond_with @engagements
  end

  def create
    if @engagement
      json_unauthorized "You or your wing have already engaged in this activity."
    end

    body = params[:engagement].delete(:body)
    params[:engagement][:user_id] = @authenticated_user.id

    @engagement = @activity.engagements.new(params[:engagement])

    if @engagement.save
      # Send the first message for this engagement
      # I'd like to hook this to the after_create event
      # but there is no way to cache the message text for this
      @engagement.send_initial_message(body)

      # Finally, respond
      respond_with @engagement, :status => :created, 
        :location => activity_engagement_path(@activity, @engagement), :template => 'engagements/show'
    else
      respond_with @engagement, :status => :unprocessable_entity
    end
  end

  def show
    # A user needs to be one of the four allowed to see this.
    return unauthorized! unless @engagement.allowed?(@authenticated_user, :all)
    respond_with @engagement
  end

  def destroy
    if @engagement.allowed?(@authenticated_user, :owner)
      # if the user is the owner of the engagement, actually delete it.
      if @engagement.destroy
        respond_with(:nothing => true) and return
      end
    elsif @activity.allowed?(@authenticated_user, :owner)
      # if the user is the owner of the activity, set status to ignored
      if @engagement.ignore!
        respond_with(:nothing => true) and return
      end
    end

    json_error "An error occured deleting this engagement."
  end

  private

  def activity_id
    params[:activity_id]
  end

  def get_engagement
    @engagement = if params[:id] == 'mine'
      get_singular_engagement
    else
      @activity.engagements.find_by_id(params[:id])      
    end

    if @engagement.nil?
      return json_not_found "You have not engaged in this activity yet, "\
        "or the engagement was not found."
    end
  end

  # only activity.participants can view index
  def engagement_owners_only
    return unauthorized! unless @engagement.allowed?(@authenticated_user, :owners)
  end

end