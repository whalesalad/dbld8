class ApplicationController < ActionController::Base

  def authenticated_user
    @authenticated_user || nil
  end

end
