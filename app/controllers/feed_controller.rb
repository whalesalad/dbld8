class FeedController < ApplicationController
  respond_to :atom

  def index
    allowed_feeds = %w(users activities events)

    unless allowed_feeds.include? params[:slug]
      render :status => 500
    end

    @slug = params[:slug]
    @model = params[:slug].classify.constantize
    
    @items = @model.unscoped.includes(:user, :wing, :location).order('created_at DESC').last(30)

    render :atom => @items
  end

end 