class HomeController < ApplicationController

  def index
    render :layout => false
  end

  def new
    # this is the new homepage
  end

  def invite
    @user = User.find_by_invite_slug(params[:invite_slug])

    # Backup, find by regular user id for ease of development
    if @user.nil?
      @user = User.find_by_id(params[:invite_slug])
    end
  end

end 