class HomeController < ApplicationController
  skip_before_filter :require_token_auth, :all

  def index
    render :layout => false
  end
end 