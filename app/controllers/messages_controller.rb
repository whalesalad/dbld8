class MessagesController < EngagementsController
  # via EngagementsController
  before_filter :get_engagement, :participants_only
  before_filter :get_message, :only => [:show, :destroy]
  after_filter :mark_messages_read, :only => [:index]

  def index
    @messages = @engagement.messages.includes(:user)

    if params.has_key?('unread') && params[:unread]
      @messages = @messages.unread_for(@authenticated_user)
    end

    respond_with @messages
  end

  def show
    @message.proxy_for(@authenticated_user).mark_read!
    respond_with @message
  end

  def create
    unless @engagement.unlocked?
      return json_error t('messages.engagement_not_unlocked')
    end

    @message = @engagement.messages.new({
      :user => @authenticated_user,
      :message => params[:message]
    })

    if @message.save
      respond_with @message,
        :status => :created, 
        :location => engagement_messages_path(@engagement),
        :template => 'messages/show'
    else
      respond_with @message, :status => :unprocessable_entity
    end
  end

  def destroy
    unless @message.allowed?(@authenticated_user, :all)
      return json_unauthorized t('messages.destroy_error')
    end

    respond_with(:nothing => true) if @message.destroy
  end

  private

  def engagement_id
    params[:engagement_id]
  end

  def get_message
    begin
      @message = @engagement.messages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return json_record_not_found(Message, params[:id])
    end
  end

  def mark_messages_read
    # Mark all of this users' proxies as unread
    @engagement.message_proxies.update_all(
      {:unread => false}, 
      {:user_id => @authenticated_user.id, :unread => true}
    )
  end

end