class FeedController < ApplicationController
  def index
    allowed_feeds = %w(users activities events)

    unless allowed_feeds.include? params[:slug]
      render :status => 500
    end

    @slug = params[:slug]
    @model = params[:slug].classify.constantize
    @items = @model.unscoped.order('created_at DESC').last(30)

    render :atom => @items
  end

end 