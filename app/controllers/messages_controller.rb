class MessagesController < EngagementsController
  respond_to :json
  
  skip_before_filter :activity_participants_only

  before_filter :get_engagement
  before_filter :get_message, :only => [:show, :destroy]

  def index
    @messages = @engagement.messages
    respond_with @messages
  end

  def show
    @message.proxy_for(@authenticated_user).mark_read!
    respond_with @message
  end

  def create
    unless @engagement.unlocked?
      return json_error "This engagement must be unlocked before replying."
    end

    @message = @engagement.messages.new({
      :user => @authenticated_user,
      :message => params[:message]
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

  def engagement_id
    params[:engagement_id]
  end

  def get_message
    @message = @engagement.messages.find_by_id(params[:id])
    json_not_found "The requested message was not found." if @message.nil?
  end

end