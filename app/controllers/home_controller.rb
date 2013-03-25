class HomeController < ApplicationController

  def index
    render :layout => false
  end

  def new
    # this is the new homepage
  end

  def invite
    if params[:invite_slug].present?
      @user = User.find_by_invite_slug()
    end

    if @user.nil?
      @user = User.find_by_id(params[:invite_slug])
    end
  end

  def email
    @email = (params[:email_slug].present?) ? params[:email_slug] : 'welcome'
    @user = User.unscoped.order("RANDOM()").first

    @title = "Hi #{@user.first_name}"
    @subtitle = "Welcome to DoubleDate!"
  end

end 