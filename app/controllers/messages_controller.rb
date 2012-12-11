class MessagesController < ApplicationController
  def index
    render json: params and return
  end

private
  
  def get_activity
    @activity = Activity.find_by_id(params[:id])
  end

end