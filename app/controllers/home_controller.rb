class HomeController < ApplicationController
  skip_filter :require_token_auth, :all

  def index
    render :layout => false
  end

  def new
    # this is the new homepage
  end

end 