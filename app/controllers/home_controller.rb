class HomeController < ApplicationController

  def index
    render :layout => false
  end

  def new
    # this is the new homepage
  end

  def invite
    if params[:invite_slug].present?
      @user = User.find_by_invite_slug(params[:invite_slug])
    end

    if @user.nil?
      @user = User.find_by_id(params[:invite_slug])
    end
  end

  def email
    @user = User.order('RANDOM()').first
    @subject = "Welcome to DoubleDate Beta!"
    render :layout => false, :template => 'user_mailer/welcome_email'
  end

end 