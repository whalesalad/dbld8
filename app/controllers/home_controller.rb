class HomeController < ApplicationController
  skip_before_filter :restrict_access, :all

  def index
    # render :layout => false
  end
end 