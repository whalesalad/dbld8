class NotificationsController < ApiController
  before_filter :get_notification, :only => [:show, :destroy]
  after_filter :mark_read, :only => [:show]

  def index
    @notifications = base_query.events.feed#.limit(20)
  end

  def show
    respond_with @notification
  end

  def destroy
    respond_with(:nothing => true) if @notification.destroy
  end

  private

  def base_query
    @authenticated_user.notifications
  end

  def get_notification
    begin
      @notification = base_query.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return json_not_found "The requested notification was not found."
    end
  end

  def mark_read
    @notification.read!
  end
end
