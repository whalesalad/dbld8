class NotificationsController < ApplicationController
  after_filter :mark_read, :only => [:show]
  respond_to :json

  def index
    @notifications = base_query.events.limit(20)
  end

  def show
    @notification = base_query.find(params[:id])
  end

  private

  def base_query
    @authenticated_user.notifications
  end

  def mark_read
    @notification.read!
  end
end
