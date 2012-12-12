class MessagesController < ApplicationController
  respond_to :json
  
  before_filter :get_engagement, :unauthorized!
  
  def index
    respond_with @engagement.messages
  end

  def show
    respond_with @engagement.messages.find_by_id(params[:id])
  end

  

private
  
  def get_engagement
    @engagement = Engagement.find_by_id(params[:engagement_id])
  end

  def unauthorized!
    unless @engagement.allowed?(@authenticated_user, :all)
      json_unauthorized "The authenticated user does not have\
      permission to modify or delete this activity."
    end
  end

end